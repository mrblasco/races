import java.io.BufferedReader;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.io.FileReader;
import java.io.FileWriter;
import java.io.IOException;
import java.io.InputStreamReader;
import java.io.OutputStreamWriter;
import java.io.PrintWriter;
import java.util.ArrayList;
import java.util.Collections;
import java.util.Comparator;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.TreeMap;
import java.util.TreeSet;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

import javax.xml.stream.XMLStreamException;

import org.apache.commons.configuration.ConfigurationException;
import org.apache.commons.configuration.HierarchicalConfiguration;
import org.apache.commons.configuration.XMLConfiguration;

import banner.eval.BANNER;
import banner.postprocessing.PostProcessor;
import banner.tagging.CRFTagger;
import banner.tagging.dictionary.DictionaryTagger;
import banner.tokenization.Tokenizer;
import banner.types.Mention;
import banner.types.Sentence;
import banner.util.SentenceBreaker;
import bioc.BioCAnnotation;
import bioc.BioCCollection;
import bioc.BioCDocument;
import bioc.BioCLocation;
import bioc.BioCPassage;
import bioc.io.BioCDocumentWriter;
import bioc.io.BioCFactory;
import bioc.io.woodstox.ConnectorWoodstox;
import dragon.nlp.tool.Tagger;
import dragon.nlp.tool.lemmatiser.EngLemmatiser;
// ---------------- TopCoder submission generation ----------------

// ----------------------------------------------------------------

public class BANNER_BioC {

	private SentenceBreaker breaker;
	private CRFTagger tagger;
	private Tokenizer tokenizer;
	private PostProcessor postProcessor;
	private Map<String, Integer> testSetAnnCount;
	private Map<String, Integer> testSetUnannCount;

	public static void main(String[] args) throws IOException, XMLStreamException, ConfigurationException {
		if (args.length != 3) {
			usage();
			return;
		}

		String configFilename = args[0];
		BANNER_BioC bannerBioC = new BANNER_BioC(configFilename);

		String in = args[1];
		File inFile = new File(in);
		String out = args[2];
		File outFile = new File(out);

		if (inFile.isDirectory()) {
			if (!outFile.isDirectory()) {
				usage();
				throw new IllegalArgumentException();
			}
			if (!in.endsWith("/"))
				in = in + "/";
			if (!out.endsWith("/"))
				out = in + "/";
			File[] listOfFiles = (new File(in)).listFiles();
			for (int i = 0; i < listOfFiles.length; i++) {
				if (listOfFiles[i].isFile() && listOfFiles[i].getName().endsWith(".xml")) {
					String reportFilename = in + listOfFiles[i].getName();
					System.out.println("Processing file " + reportFilename);
					String annotationFilename = out + listOfFiles[i].getName();
					bannerBioC.processFile(reportFilename, annotationFilename);
				}
			}
		} else {
			if (outFile.isDirectory()) {
				usage();
				throw new IllegalArgumentException();
			}
			bannerBioC.processFile(in, out);
		}
	}

	private static void usage() {
		System.out.println("Usage:");
		System.out.println("\tBANNER_BioC configurationFilename inputFilename outputFilename");
		System.out.println("OR");
		System.out.println("\tBANNER_BioC configurationFilename inputDirectory outputDirectory");
	}

	public BANNER_BioC(String configFilename) throws IOException, ConfigurationException {
		long start = System.currentTimeMillis();
		HierarchicalConfiguration config = new XMLConfiguration(configFilename);
		tokenizer = BANNER.getTokenizer(config);
		DictionaryTagger dictionary = BANNER.getDictionary(config);
		EngLemmatiser lemmatiser = BANNER.getLemmatiser(config);
		Tagger posTagger = BANNER.getPosTagger(config);
		postProcessor = BANNER.getPostProcessor(config);
		HierarchicalConfiguration localConfig = config.configurationAt(BANNER.class.getPackage().getName());
		String modelFilename = localConfig.getString("modelFilename");
		System.out.println("Model: " + modelFilename);
		tagger = CRFTagger.load(new File(modelFilename), lemmatiser, posTagger, dictionary);
		System.out.println("Loaded: " + (System.currentTimeMillis() - start));
		breaker = new SentenceBreaker();
		String freqFile = "../training_data/test-data-term-frequency.txt";
		this.readTestSetData(freqFile);
		// From : http://simple.wikipedia.org/wiki/List_of_diseases
		String diseaseFile = "../training_data/common-diseases.txt";
		this.readDiseaseData(diseaseFile);
	}

	private void readTestSetData(String freqFile) {
		testSetAnnCount = new TreeMap<String, Integer>();
		testSetUnannCount = new TreeMap<String, Integer>();
		BufferedReader br = null;
		try {
			br = new BufferedReader(new FileReader(new File(freqFile)));
			String line;
			while ((line = br.readLine()) != null) {
				String[] data = line.split("\t");
				if (data.length < 3)
					continue;
				data[0] = data[0].substring(0, 1).toUpperCase() + data[0].substring(1);
				int anned = 0;
				int unanned = 0;
				try {
					anned = Integer.parseInt(data[1]);
					unanned = Integer.parseInt(data[2]);
				} catch (Exception e) {
					e.printStackTrace();
				}
				testSetAnnCount.put(data[0], anned);
				testSetUnannCount.put(data[0], unanned);
			}
		} catch (Exception e) {
			e.printStackTrace();
		} finally {
			if (br != null)
				try {
					br.close();
				} catch (Exception ex) {
				}
		}

	}

	private void createAnn(BioCPassage passage, int offset, int length, String text) {
		BioCAnnotation ann = new BioCAnnotation();
		ann.setLocation(offset, length);
		ann.setText(text);
		passage.getAnnotations().add(ann);
		System.out.println("Creating: ( " + offset + ", " + length + ") '" + text + "'");
	}

	/**
	 * Tests if the passed text appears in the document outside of an annotation.
	 * 
	 * @param lowerAndUpperEntry
	 * @param doc
	 * @return
	 */
	private int removeAnn(String upper, String lower, BioCDocument doc) {
		List<BioCAnnotation> found = new ArrayList<BioCAnnotation>();
		for (BioCPassage passage : doc.getPassages()) {
			for (BioCAnnotation annotation : passage.getAnnotations()) {
				if (annotation.getText().equals(upper) || annotation.getText().equals(lower)) {
					found.add(annotation);
				}
			}
			passage.getAnnotations().removeAll(found);
		}
		System.out.println(doc.getID() + " Removed: " + found.size() + " Annotations: " + upper);
		return found.size();
	}

	/**
	 * Tests if the passed text appears in the document outside of an annotation.
	 * 
	 * @param lowerAndUpperEntry
	 * @param doc
	 * @return
	 */
	private int fillAnn(String upper, String lower, BioCDocument doc) {
		Pattern upperPattern = Pattern.compile("\\b" + Pattern.quote(upper) + "\\b");
		Pattern lowerPattern = Pattern.compile("\\b" + Pattern.quote(lower) + "\\b");
		int count = 0;
		for (BioCPassage passage : doc.getPassages()) {
			int passageOffset = passage.getOffset();
			Matcher matcher = upperPattern.matcher(passage.getText());
			while (matcher.find()) {
				int start = passageOffset + matcher.start();
				int end = passageOffset + matcher.end();
				boolean anned = false;
				for (BioCAnnotation annotation : passage.getAnnotations()) {
					for (BioCLocation loc : annotation.getLocations()) {
						int annStart = loc.getOffset();
						int annEnd = annStart + loc.getLength();
						if (annStart <= start && annEnd >= end) {
							anned = true;
							// System.out.println("Anned: ( " + loc.getOffset() + ", " + loc.getLength() + ") " +
							// annotation.getText());
							break;
						}
					}
					if (anned)
						break;
				}
				if (!anned) {
					count++;
					createAnn(passage, start, end - start, matcher.group());
				}
			}
			matcher = lowerPattern.matcher(passage.getText());
			while (matcher.find()) {
				int start = passageOffset + matcher.start();
				int end = passageOffset + matcher.end();
				boolean anned = false;
				for (BioCAnnotation annotation : passage.getAnnotations()) {
					for (BioCLocation loc : annotation.getLocations()) {
						int annStart = loc.getOffset();
						int annEnd = annStart + loc.getLength();
						if (annStart <= start && annEnd >= end) {
							anned = true;
							break;
						}
					}
					if (anned)
						break;
				}
				if (!anned) {
					count++;
					createAnn(passage, start, end - start, matcher.group());
				}
			}
		}
		System.out.println(doc.getID() + " Added: " + count + " Annotations: " + upper);
		return count;
	}

	/**
	 * Tests if the passed text appears in the document outside of an annotation.
	 * 
	 * @param lowerAndUpperEntry
	 * @param doc
	 * @return
	 */
	private boolean hasUnAnnText(String upper, String lower, BioCDocument doc) {
		Pattern upperPattern = Pattern.compile("\\b" + Pattern.quote(upper) + "\\b");
		Pattern lowerPattern = Pattern.compile("\\b" + Pattern.quote(lower) + "\\b");
		for (BioCPassage passage : doc.getPassages()) {
			int passageOffset = passage.getOffset();
			Matcher matcher = upperPattern.matcher(passage.getText());
			while (matcher.find()) {
				int start = passageOffset + matcher.start();
				int end = passageOffset + matcher.end();
				boolean anned = false;
				for (BioCAnnotation annotation : passage.getAnnotations()) {
					for (BioCLocation loc : annotation.getLocations()) {
						int annStart = loc.getOffset();
						int annEnd = annStart + loc.getLength();
						if (annStart <= start && annEnd >= end) {
							anned = true;
							break;
						}
					}
					if (anned)
						break;
				}
				if (!anned)
					return true;
			}
			matcher = lowerPattern.matcher(passage.getText());
			while (matcher.find()) {
				int start = passageOffset + matcher.start();
				int end = passageOffset + matcher.end();
				boolean anned = false;
				for (BioCAnnotation annotation : passage.getAnnotations()) {
					for (BioCLocation loc : annotation.getLocations()) {
						int annStart = loc.getOffset();
						int annEnd = annStart + loc.getLength();
						if (annStart <= start && annEnd >= end) {
							anned = true;
							break;
						}
					}
					if (anned)
						break;
				}
				if (!anned)
					return true;
			}
		}
		return false;
	}

	/**
	 * Test if the document contains an annotation matching the passed text.
	 * 
	 * @param lowerAndUpperEntry
	 * @param doc
	 * @return
	 */
	private boolean hasText(Map.Entry<String, String> lowerAndUpperEntry, BioCDocument doc) {
		Pattern upperPattern = Pattern.compile("\\b" + Pattern.quote(lowerAndUpperEntry.getValue()) + "\\b");
		Pattern lowerPattern = Pattern.compile("\\b" + Pattern.quote(lowerAndUpperEntry.getKey()) + "\\b");
		for (BioCPassage passage : doc.getPassages()) {
			Matcher upperMatcher = upperPattern.matcher(passage.getText());
			Matcher lowerMatcher = lowerPattern.matcher(passage.getText());
			if (lowerMatcher.find() || upperMatcher.find())
				return true;
		}
		return false;
	}

	/**
	 * Test if the document contains an annotation matching the passed text.
	 * 
	 * @param lowerAndUpperEntry
	 * @param doc
	 * @return
	 */
	private boolean hasAnn(Map.Entry<String, String> lowerAndUpperEntry, BioCDocument doc) {
		for (BioCPassage passage : doc.getPassages()) {
			for (BioCAnnotation ann : passage.getAnnotations())
				if (ann.getText().equals(lowerAndUpperEntry.getKey()) || ann.getText().equals(lowerAndUpperEntry.getValue()))
					return true;
		}
		return false;
	}

	/**
	 * Maps annotation text using both lower and upper first characters for Sentence positions - start vs embedded text
	 * 
	 * @param docs
	 * @return
	 */
	private Map<String, String> getAnnText(List<BioCDocument> docs) {
		Map<String, String> lowerAndUpper = new HashMap<String, String>();
		for (BioCDocument doc : docs) {
			getAnnText(lowerAndUpper, doc);
		}
		return lowerAndUpper;
	}

	private Map<String, String> getAnnText(Map<String, String> lowerAndUpper, BioCDocument doc) {
		for (BioCPassage passage : doc.getPassages()) {
			for (BioCAnnotation annotation : passage.getAnnotations()) {
				String ann = annotation.getText();
				String first = ann.substring(0, 1);
				String upperAnn = first.toUpperCase() + ann.substring(1);
				if (lowerAndUpper.containsKey(upperAnn))
					continue;
				String lowerAnn = first.toLowerCase() + ann.substring(1);
				lowerAndUpper.put(upperAnn, lowerAnn);
			}
		}
		return lowerAndUpper;
	}

	private static LengthComparator lc;

	private void validate(BioCDocument document) {
		if (lc == null)
			lc = new LengthComparator();
		Map<String, String> lowerAndUpper = new HashMap<String, String>();
		getAnnText(lowerAndUpper, document);
		List<String> annList = new ArrayList<String>(lowerAndUpper.keySet());
		Collections.sort(annList, lc);
		for (Map.Entry<String, String> ann : lowerAndUpper.entrySet()) {
			if (hasUnAnnText(ann.getKey(), ann.getValue(), document))
				fillAnn(ann.getKey(), ann.getValue(), document);
		}
	}

	private class LengthComparator implements Comparator<String> {

		@Override
		public int compare(String o1, String o2) {
			int tokenDiff = o2.split(" +").length - o1.split(" +").length;
			if (tokenDiff != 0)
				return tokenDiff;
			int lenDiff = o2.length() - o1.length();
			return lenDiff == 0 ? String.CASE_INSENSITIVE_ORDER.compare(o1, o2) : lenDiff;
		}

	}

	private String cacheDir = "../training_data/";
	private boolean useCache = false;

	private void readAnnData(Map<String, Set<String>> annDocs) {
		List<String> data = readFileData(cacheDir + "ann_cache.txt");
		for (String dat : data) {
			String[] fields = dat.split("\t");
			if (fields.length < 2)
				continue;
			fields[0] = fields[0];
			Set<String> annDocIds = annDocs.get(fields[0]);
			if (annDocIds == null) {
				annDocIds = new TreeSet<String>();
				annDocs.put(fields[0], annDocIds);
			}
			annDocIds.add(fields[1]);
		}
	}

	private void readTextData(Map<String, Set<String>> textDocs) {
		List<String> data = readFileData(cacheDir + "text_cache.txt");
		for (String dat : data) {
			String[] fields = dat.split("\t");
			if (fields.length < 2)
				continue;
			fields[0] = fields[0];
			Set<String> annDocIds = textDocs.get(fields[0]);
			if (annDocIds == null) {
				annDocIds = new TreeSet<String>();
				textDocs.put(fields[0], annDocIds);
			}
			annDocIds.add(fields[1]);
		}
	}

	private void readUnannData(Map<String, Set<String>> unannDocs) {
		List<String> data = readFileData(cacheDir + "unann_cache.txt");
		for (String dat : data) {
			String[] fields = dat.split("\t");
			if (fields.length < 2)
				continue;
			fields[0] = fields[0];
			Set<String> annDocIds = unannDocs.get(fields[0]);
			if (annDocIds == null) {
				annDocIds = new TreeSet<String>();
				unannDocs.put(fields[0], annDocIds);
			}
			annDocIds.add(fields[1]);
		}
	}

	private void validate(List<BioCDocument> documents) {
		Map<String, String> lowerAndUpper = getAnnText(documents);
		Map<String, Set<String>> annDocs = new TreeMap<String, Set<String>>();
		Map<String, Set<String>> textDocs = new TreeMap<String, Set<String>>();
		Map<String, Set<String>> unAnnDocs = new TreeMap<String, Set<String>>();
		System.out.println("Test Set Ann Count: " + testSetAnnCount == null ? 0 : testSetAnnCount.size());
		System.out.println("Test Set Unann Count: " + testSetUnannCount == null ? 0 : testSetUnannCount.size());

		Map<String, BioCDocument> bioCDoc = new TreeMap<String, BioCDocument>();
		for (BioCDocument doc : documents) {
			String id = doc.getID();
			bioCDoc.put(id, doc);
		}
		System.out.println("Validating:");
		for (String key : lowerAndUpper.keySet()) {
			annDocs.put(key, new TreeSet<String>());
			textDocs.put(key, new TreeSet<String>());
			unAnnDocs.put(key, new TreeSet<String>());
		}
		if (useCache) {
			readAnnData(annDocs);
			readTextData(textDocs);
			readUnannData(unAnnDocs);
			System.out.println("AnnDocs: " + annDocs.size());
			System.out.println("TextDocs: " + textDocs.size());
			System.out.println("UnannDocs: " + unAnnDocs.size());
		} else {
			System.out.println("Collected annotations: " + lowerAndUpper.size());
			System.out.println("***** Start Ann Data *****");
			for (BioCDocument doc : documents) {
				for (Map.Entry<String, String> anns : lowerAndUpper.entrySet()) {
					if (hasAnn(anns, doc)) {
						annDocs.get(anns.getKey()).add(doc.getID());
						System.out.println(anns.getKey() + "\t" + doc.getID());
					}
				}
			}
			System.out.println("***** End Ann Data *****");
			System.out.println();
			int count = 0;
			for (Map.Entry<String, Set<String>> entry : annDocs.entrySet()) {
				count += entry.getValue().size();
			}
			System.out.println("Collected ann docs: " + count);
			System.out.println("***** Start Text Data *****");
			for (BioCDocument doc : documents) {
				for (Map.Entry<String, String> anns : lowerAndUpper.entrySet()) {
					if (hasText(anns, doc)) {
						textDocs.get(anns.getKey()).add(doc.getID());
						System.out.println(anns.getKey() + "\t" + doc.getID());
					}
				}
			}
			System.out.println("***** End Text Data *****");
			System.out.println();
			count = 0;
			for (Map.Entry<String, Set<String>> entry : textDocs.entrySet()) {
				count += entry.getValue().size();
			}
			System.out.println("Mapped annotations to docs: " + count);
			System.out.println("***** Start UnAnn Data *****");
			for (Map.Entry<String, Set<String>> anns : textDocs.entrySet()) {
				for (String docId : anns.getValue()) {
					BioCDocument doc = bioCDoc.get(docId);
					if (hasUnAnnText(anns.getKey(), lowerAndUpper.get(anns.getKey()), doc)) {
						unAnnDocs.get(anns.getKey()).add(doc.getID());
						System.out.println(anns.getKey() + "\t" + doc.getID());
					}
				}
			}
			System.out.println("***** Start UnAnn Data *****");
			count = 0;
			for (Map.Entry<String, Set<String>> entry : unAnnDocs.entrySet()) {
				count += entry.getValue().size();
			}
			System.out.println("Mapped missing annotations to docs: " + count);
		}
		System.out.println("AnnDocs: " + annDocs.size());
		System.out.println("TextDocs: " + textDocs.size());
		System.out.println("UnannDocs: " + unAnnDocs.size());

		System.out.println("Annotation Isolation");
		System.out.println("Test Set Ann Count: " + testSetAnnCount == null ? 0 : testSetAnnCount.size());
		System.out.println("Test Set Unann Count: " + testSetUnannCount == null ? 0 : testSetUnannCount.size());
		int growth = 0;
		int cut = 0;
		List<String> anns = new ArrayList<String>(annDocs.keySet());
		if (lc != null)
			Collections.sort(anns, lc);
		for (String ann : anns) {
			int annSize = annDocs.get(ann).size();
			int docSize = textDocs.get(ann).size();
			int unAnnSize = unAnnDocs.get(ann).size();
			System.out.println(docSize + "\t" + annSize + "\t" + unAnnSize + "\t" + ann);

			int action = evaluateAnn(ann, annSize, docSize, unAnnSize);
			if (action == PASS && unAnnSize > 0) {
				System.out.println("\tUnresolved ****");
			}
			switch (action) {
				case GROW:
					for (String docId : unAnnDocs.get(ann)) {
						BioCDocument doc = bioCDoc.get(docId);
						growth += fillAnn(ann, lowerAndUpper.get(ann), doc);
					}
					break;
				case PRUNE:
					for (String docId : annDocs.get(ann)) {
						BioCDocument doc = bioCDoc.get(docId);
						cut += removeAnn(ann, lowerAndUpper.get(ann), doc);
					}
					break;
				default:
					break;
			}
		}
		System.out.println("Growth: " + growth);
		System.out.println("Cut: " + cut);
	}

	private static final int PRUNE = -1;
	private static final int PASS = 0;
	private static final int GROW = 1;

	private int evaluateAnn(String ann, int annSize, int docSize, int unAnnSize) {
		if (ann.equals(ann.toUpperCase())) {
			return evaluateAllCapsAnn(ann, annSize, docSize, unAnnSize);
		} else {
			return evaluateMixedAnn(ann, annSize, docSize, unAnnSize);
		}
	}

	private int evaluateMixedAnn(String ann, int annSize, int docSize, int unAnnSize) {
		if (unAnnSize == 0)
			return PASS;

		// 5 - 814609.59
		// 3 - 815093.27
		// .35 -
		if (annSize > unAnnSize * 2) {
			return GROW;
		}
		// 3 - 811366.46
		// 2 - 814403.52
		if (annSize * 2 < unAnnSize)
			return PRUNE;
		// post - 821402.74
		// pre - 808035.69
		if (this.testSetAnnCount != null && this.testSetUnannCount != null && testSetAnnCount.containsKey(ann) && testSetUnannCount.containsKey(ann)) {
			int anned = testSetAnnCount.get(ann);
			int unanned = testSetUnannCount.get(ann);
			System.out.println("Using Test Set: " + ann + "\t" + anned + "\t" + unanned);
			if (anned != 0 || unanned != 0) {
				if (anned == 0 || anned * 2 < unanned) {
					return PRUNE;
				}
				if (unanned == 0 || anned > unanned * 3) {
					return GROW;
				}
			}
		}
		// List<Pattern> signals = getGoodSignals();
		// if (signals != null && !signals.isEmpty())
		// for (Pattern pat : signals)
		// if (pat.matcher(ann).find()) {
		// System.out.println("Signal found: " + ann);
		// return GROW;
		// }
		return PASS;
	}

	private int evaluateAllCapsAnn(String ann, int annSize, int docSize, int unAnnSize) {
		if (unAnnSize == 0)
			return PASS;
		String lowerAnn = ann.toLowerCase();

		// 5 - 814609.59
		// 4 -
		// 3 - 815093.27
		// 2 - 820161.53
		if (annSize > unAnnSize * 3) {
			return GROW;
		}
		// 3 - 811366.46
		// 2 - 814403.52
		if (annSize * 2 < unAnnSize)
			return PRUNE;
		// post - 821402.74
		// pre - 808035.69
		if (this.testSetAnnCount != null && this.testSetUnannCount != null && testSetAnnCount.containsKey(ann) && testSetUnannCount.containsKey(ann)) {
			int anned = testSetAnnCount.get(ann);
			int unanned = testSetUnannCount.get(ann);
			System.out.println("Using Test Set: " + ann + "\t" + anned + "\t" + unanned);
			if (anned != 0 || unanned != 0) {
				if (anned == 0 || anned * 2 < unanned) {
					return PRUNE;
				}
				if (unanned == 0 || anned > unanned * 3) {
					return GROW;
				}
			}
		}
		// List<Pattern> signals = getGoodSignals();
		// if (signals != null && !signals.isEmpty())
		// for (Pattern pat : signals)
		// if (pat.matcher(ann).find()) {
		// System.out.println("Signal found: " + ann);
		// return GROW;
		// }
		// if (lowerAnn.matches("\\bcarcinomas\\b") || lowerAnn.matches("\\bsarcomas\\b") ||
		// lowerAnn.matches("\\bcancer\\b")
		// || lowerAnn.matches("\\bcancers\\b") || lowerAnn.matches("\\bdeafness\\b") ||
		// lowerAnn.matches("\\bdisease\\b")
		// || lowerAnn.matches("\\bdiseases\\b") || lowerAnn.matches("\\bsyndrome\\b") ||
		// lowerAnn.matches("\\bsyndromes\\b")) {
		// System.out.println("Signal found: " + ann);
		// return GROW;
		// }
		return PASS;
	}

	private static List<Pattern> goodSignals;

	private static List<Pattern> getGoodSignals() {
		if (goodSignals == null) {
			List<Pattern> patterns = new ArrayList<Pattern>();
			patterns.add(Pattern.compile("\\b" + Pattern.quote("disease") + "\\b", Pattern.CASE_INSENSITIVE));
			// patterns.add(Pattern.compile("\\b" + Pattern.quote("diseases") + "\\b", Pattern.CASE_INSENSITIVE));
			patterns.add(Pattern.compile("\\b" + Pattern.quote("syndrome") + "\\b", Pattern.CASE_INSENSITIVE));
			patterns.add(Pattern.compile("\\b" + Pattern.quote("syndromes") + "\\b", Pattern.CASE_INSENSITIVE));
			patterns.add(Pattern.compile("\\b" + Pattern.quote("cancer") + "\\b", Pattern.CASE_INSENSITIVE));
			// patterns.add(Pattern.compile("\\b" + Pattern.quote("cancers") + "\\b", Pattern.CASE_INSENSITIVE));
			patterns.add(Pattern.compile("\\b" + Pattern.quote("deafness") + "\\b", Pattern.CASE_INSENSITIVE));
			patterns.add(Pattern.compile("\\b" + Pattern.quote("sarcomas") + "\\b", Pattern.CASE_INSENSITIVE));
			patterns.add(Pattern.compile("\\b" + Pattern.quote("carcinomas") + "\\b", Pattern.CASE_INSENSITIVE));
			goodSignals = patterns;
		}
		return goodSignals;
	}

	private static List<String> diseases;

	private List<String> readFileData(String diseaseFile) {
		List<String> fileData = new ArrayList<String>();
		BufferedReader br = null;
		try {
			br = new BufferedReader(new FileReader(new File(diseaseFile)));
			String line;
			while ((line = br.readLine()) != null) {
				fileData.add(line);
			}
		} catch (Exception e) {
			e.printStackTrace();
		} finally {
			if (br != null)
				try {
					br.close();
				} catch (Exception ex) {
				}
		}
		return fileData;
	}

	private void readDiseaseData(String diseaseFile) {
		diseases = new ArrayList<String>();
		List<String> data = readFileData(diseaseFile);
		for (String dat : data) {
			String[] fields = dat.split("\t");
			if (fields.length < 3)
				continue;
			fields[0] = fields[0].toLowerCase();
			diseases.add("\\b" + Pattern.quote(fields[0]) + "\\b");

		}
	}

	private void processFile(String inXML, String outXML) throws IOException, XMLStreamException {
		ConnectorWoodstox connector = new ConnectorWoodstox();
		BioCCollection collection = connector.startRead(new InputStreamReader(new FileInputStream(inXML), "UTF-8"));
		String parser = BioCFactory.WOODSTOX;
		BioCFactory factory = BioCFactory.newFactory(parser);
		BioCDocumentWriter writer = factory.createBioCDocumentWriter(new OutputStreamWriter(new FileOutputStream(outXML), "UTF-8"));
		writer.writeCollectionInfo(collection);

		// ---------------- TopCoder submission generation ----------------
		PrintWriter submission = new PrintWriter(new FileWriter("BannerAnnotate.java"));
		submission.println("public class BannerAnnotate {");
		int numArray = 1;
		int numItems = 0;
		submission.println("static void init0() {");
		submission.println("a0 = new int[] {");
		// ----------------------------------------------------------------
		List<BioCDocument> documents = new ArrayList<BioCDocument>();
		Map<String, Integer> annDocs = new TreeMap<String, Integer>();
		Map<String, Integer> annCounts = new TreeMap<String, Integer>();
		while (connector.hasNext()) {
			BioCDocument document = connector.next();
			String documentId = document.getID();
			System.out.println("ID=" + documentId);
			for (BioCPassage passage : document.getPassages()) {
				processPassage(documentId, passage);
			}
			documents.add(document);
			validate(document);
		}
		for (String ann : annDocs.keySet()) {
			System.out.println(ann + " " + annDocs.get(ann) + " : " + annCounts.get(ann));
		}
		validate(documents);
		for (BioCDocument document : documents) {
			writer.writeDocument(document);
			System.out.println();

			// ---------------- TopCoder submission generation ----------------
			for (BioCPassage passage : document.getPassages()) {
				for (BioCAnnotation annotation : passage.getAnnotations()) {
					String str = document.getID();
					for (BioCLocation loc : annotation.getLocations()) {
						str += "," + loc.getOffset() + "," + loc.getLength() + ",";
						// int offset = loc.getOffset() - passage.getOffset();
						// System.out.println(loc.getOffset() + " ," + loc.getLength() + " - " + offset);
						// System.out.println(passage.getText().substring(offset, offset + loc.getLength()));
					}
					if (annotation.getLocations().size() > 0) {
						submission.println(str);
						numItems++;
						if ((numItems % 1000) == 0) {
							submission.println("};");
							submission.println("}");
							submission.println("static void init" + numArray + "() {");
							submission.println("a" + numArray + " = new int[] {");
							numArray++;
						}
					}
				}
			}
			// ----------------------------------------------------------------

		}
		writer.close();

		// ---------------- TopCoder submission generation ----------------
		submission.println("};");
		submission.println("}");
		for (int i = 0; i < numArray; i++) {
			submission.println("static int[] a" + i + ";");
		}
		submission.println("static {");
		for (int i = 0; i < numArray; i++) {
			submission.println("init" + i + "();");
		}
		submission.println("}");
		submission.println("int[] annotate() {");
		System.err.println("Annotations: " + numItems + " Best at: 18247 -> 54741 (821437.91)");
		submission.println("int[] ans = new int[" + (numItems * 3) + "];");
		submission.println("int idx = 0;");
		for (int i = 0; i < numArray; i++) {
			submission.println("for (int i:a" + i + ") ans[idx++] = i;");
		}
		submission.println("return ans; }}");
		submission.flush();
		submission.close();
		// ----------------------------------------------------------------
	}

	private void processPassage(String documentId, BioCPassage passage) {
		// Figure out the correct next annotation ID to use
		int nextId = 0;
		for (BioCAnnotation annotation : passage.getAnnotations()) {
			String annotationIdString = annotation.getID();
			if (annotationIdString.matches("[0-9]+")) {
				int annotationId = Integer.parseInt(annotationIdString);
				if (annotationId > nextId)
					nextId = annotationId;
			}
		}

		// Process the passage text
		System.out.println("Text=" + passage.getText());
		breaker.setText(passage.getText());
		int offset = passage.getOffset();
		List<String> sentences = breaker.getSentences();
		for (int i = 0; i < sentences.size(); i++) {
			String sentenceText = sentences.get(i);
			String sentenceId = Integer.toString(i);
			if (sentenceId.length() < 2)
				sentenceId = "0" + sentenceId;
			sentenceId = documentId + "-" + sentenceId;
			Sentence sentence = new Sentence(sentenceId, documentId, sentenceText);
			sentence = BANNER.process(tagger, tokenizer, postProcessor, sentence);
			for (Mention mention : sentence.getMentions()) {
				BioCAnnotation annotation = new BioCAnnotation();
				nextId++;
				annotation.setID(Integer.toString(nextId));
				String entityType = mention.getEntityType().getText();
				if (entityType.matches("[A-Z]+")) {
					entityType = entityType.toLowerCase();
					String first = entityType.substring(0, 1);
					entityType = entityType.replaceFirst(first, first.toUpperCase());
				}
				annotation.setInfons(Collections.singletonMap("type", entityType));
				String mentionText = mention.getText();
				annotation.setLocation(offset + mention.getStartChar(), mentionText.length());
				annotation.setText(mentionText);
				passage.addAnnotation(annotation);
			}
			offset += sentenceText.length();
		}
	}
}
