package banner.eval.dataset;

import java.awt.Point;
import java.io.File;
import java.io.IOException;
import java.util.ArrayList;
import java.util.Comparator;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.TreeMap;
import java.util.TreeSet;

import javax.xml.parsers.DocumentBuilder;
import javax.xml.parsers.DocumentBuilderFactory;
import javax.xml.parsers.ParserConfigurationException;

import org.w3c.dom.Document;
import org.w3c.dom.Element;
import org.w3c.dom.NodeList;
import org.xml.sax.SAXException;

public class DataSetAnalysis {
	private static PointComparator pc;

	public static void main(String[] args) {
		if (args == null || args.length == 0)
			return;
		String testDir = args[0];
		pc = new DataSetAnalysis().new PointComparator();
		File tDir = new File(testDir);

		Map<Document, File> xmiDocs = new HashMap<Document, File>();

		for (File f : tDir.listFiles()) {
			if (!f.getName().endsWith(".xml"))
				continue;
			System.out.println("File: " + f.getName());
			Document doc = fileToDocument(f.getAbsolutePath());
			xmiDocs.put(doc, f);
		}
		Map<String, List<Element>> docIds = getDocIds(xmiDocs.keySet());
		Map<String, Map<Integer, String>> docPassages = getDocPassages(docIds);
		Map<String, TreeSet<Point>> docAnnotations = getDocAnnotations(docIds);
		Map<String, Set<String>> unAnnedText = new TreeMap<String, Set<String>>();
		Map<String, Set<String>> unAnnedDictionary = new TreeMap<String, Set<String>>();
		Map<String, Set<String>> annedText = new TreeMap<String, Set<String>>();
		Map<String, Set<String>> annedDictionary = new TreeMap<String, Set<String>>();
		for (String docId : docPassages.keySet()) {
			System.out.println("Doc ID: " + docId);
			Map<Integer, String> passages = docPassages.get(docId);
			TreeSet<Point> anns = docAnnotations.get(docId);
			Set<String> annText = getAnnedText(passages, anns);
			annedText.put(docId, annText);
			Set<String> annDict = getAnnDict(annText);
			annedDictionary.put(docId, annDict);
			for (String aText : annDict) {
				System.out.println("\tAnned: '" + aText + "'");
			}
			Set<String> unAnnText = getUnannedText(passages, anns);
			unAnnedText.put(docId, unAnnText);
			Set<String> unannDict = getUnannDict(unAnnText);
			unannDict.removeAll(annDict);
			unAnnedDictionary.put(docId, unannDict);
			System.out.println();
			for (String aText : unannDict) {
				System.out.println("\tUnanned: '" + aText + "'");
			}
			System.out.println();
		}
		Map<String, Integer> annDocs = new TreeMap<String, Integer>();
		Map<String, Integer> unannDocs = new TreeMap<String, Integer>();
		Set<String> dictionary = new TreeSet<String>();
		for (Set<String> dict : annedDictionary.values())
			dictionary.addAll(dict);
		for (Set<String> dict : unAnnedDictionary.values())
			dictionary.addAll(dict);
		for (String term : dictionary) {
			annDocs.put(term, 0);
			unannDocs.put(term, 0);
		}
		for (Map.Entry<String, Set<String>> entry : annedDictionary.entrySet()) {
			for (String term : entry.getValue())
				annDocs.put(term, annDocs.get(term) + 1);
		}
		for (Map.Entry<String, Set<String>> entry : unAnnedDictionary.entrySet()) {
			for (String term : entry.getValue())
				unannDocs.put(term, unannDocs.get(term) + 1);
		}
		for (String term : dictionary) {
			System.out.println(term + "\t" + annDocs.get(term) + "\t" + unannDocs.get(term));
		}
	}

	private static Set<String> getUnannDict(Set<String> unAnnText) {
		Set<String> dict = new TreeSet<String>();
		List<String> texts = new ArrayList<String>(unAnnText);
		for (int i = 0; i < texts.size(); i++) {
			String[] values = texts.get(i).split(" +");
			for (int j = 0; j < values.length; j++) {
				if (values[j].length() == 0)
					continue;
				StringBuilder sb = new StringBuilder();
				sb.append(values[j].substring(0, 1).toUpperCase() + values[j].substring(1));
				dict.add(sb.toString());
				if (j + 1 < values.length) {
					sb.append(" ").append(values[j + 1]);
					dict.add(sb.toString());
				}
				if (j + 2 < values.length) {
					sb.append(" ").append(values[j + 2]);
					dict.add(sb.toString());
				}
				if (j + 3 < values.length) {
					sb.append(" ").append(values[j + 3]);
					dict.add(sb.toString());
				}
			}
		}
		return dict;
	}

	private static Set<String> getAnnDict(Set<String> annText) {
		Set<String> dict = new TreeSet<String>();
		for (String ann : annText)
			if (ann.length() > 0 && ann.split(" ").length < 4)
				dict.add(ann.substring(0, 1).toUpperCase() + ann.substring(1));
		return dict;
	}

	private static String merge(Map<Integer, String> passages) {
		StringBuilder sb = new StringBuilder();
		for (Map.Entry<Integer, String> passage : passages.entrySet())
			sb.append(passage.getValue());
		return sb.toString();
	}

	private static Set<String> getUnannedText(Map<Integer, String> passages, TreeSet<Point> anns) {
		Set<String> text = new TreeSet<String>();

		int currentStart = 0;
		int end = merge(passages).length();
		for (Point p : anns) {
			if (p.x <= currentStart) {
				currentStart = p.x + p.y;
			} else
				for (Map.Entry<Integer, String> entry : passages.entrySet()) {
					if (currentStart >= entry.getKey() && currentStart < entry.getKey() + entry.getValue().length()) {
						if (p.x < entry.getKey() + entry.getValue().length()) {
							text.add(entry.getValue().substring(currentStart - entry.getKey(), p.x - entry.getKey()));
							currentStart = p.x + p.y;
						} else {
							text.add(entry.getValue().substring(currentStart - entry.getKey()));
							currentStart = entry.getKey() + entry.getValue().length();
						}
						break;
					}
				}
		}
		return text;
	}

	private static Set<String> getAnnedText(Map<Integer, String> passages, Set<Point> anns) {
		Set<String> text = new TreeSet<String>();
		for (Point p : anns) {
			for (Map.Entry<Integer, String> entry : passages.entrySet()) {
				if (p.x >= entry.getKey() && p.x + p.y <= entry.getKey() + entry.getValue().length()) {
					int start = p.x - entry.getKey();
					int end = start + p.y;
					text.add(entry.getValue().substring(start, end));
					break;
				}
			}
		}
		return text;
	}

	private static Map<String, TreeSet<Point>> getDocAnnotations(Map<String, List<Element>> docIds) {
		Map<String, TreeSet<Point>> docAnnotations = new TreeMap<String, TreeSet<Point>>();
		for (Map.Entry<String, List<Element>> entry : docIds.entrySet()) {
			TreeSet<Point> annotations = new TreeSet<Point>(pc);
			for (Element doc : entry.getValue()) {
				NodeList passageNodes = doc.getElementsByTagName("annotation");
				for (int i = 0; i < passageNodes.getLength(); i++) {
					NodeList kids = passageNodes.item(i).getChildNodes();
					String offset = null;
					String length = null;
					for (int j = 0; j < kids.getLength(); j++) {
						if ("location".equals(kids.item(j).getNodeName())) {
							offset = ((Element) kids.item(j)).getAttribute("offset");
							length = ((Element) kids.item(j)).getAttribute("length");
						}
					}
					annotations.add(new Point(Integer.parseInt(offset), Integer.parseInt(length)));
				}
			}
			docAnnotations.put(entry.getKey(), annotations);
		}
		return docAnnotations;
	}

	private static Map<String, Map<Integer, String>> getDocPassages(Map<String, List<Element>> docIds) {
		Map<String, Map<Integer, String>> docPassages = new TreeMap<String, Map<Integer, String>>();
		for (Map.Entry<String, List<Element>> entry : docIds.entrySet()) {
			Map<Integer, String> passages = new TreeMap<Integer, String>();
			for (Element doc : entry.getValue()) {
				NodeList passageNodes = doc.getElementsByTagName("passage");
				for (int i = 0; i < passageNodes.getLength(); i++) {
					NodeList kids = passageNodes.item(i).getChildNodes();
					String offset = null;
					String text = null;
					for (int j = 0; j < kids.getLength(); j++) {
						if ("text".equals(kids.item(j).getNodeName()))
							text = kids.item(j).getTextContent();
						if ("offset".equals(kids.item(j).getNodeName()))
							offset = kids.item(j).getTextContent();
					}
					passages.put(Integer.parseInt(offset), text);
				}
			}
			docPassages.put(entry.getKey(), passages);
		}
		return docPassages;
	}

	public static Map<String, List<Element>> getDocIds(Set<Document> docs) {
		Map<String, List<Element>> idDocs = new TreeMap<String, List<Element>>();
		for (Document doc : docs) {
			NodeList docNodes = doc.getElementsByTagName("document");
			for (int i = 0; i < docNodes.getLength(); i++) {
				Element docEle = (Element) docNodes.item(i);
				String id = docEle.getElementsByTagName("id").item(0).getTextContent();
				List<Element> docEles = idDocs.get(id);
				if (docEles == null) {
					docEles = new ArrayList<Element>();
					idDocs.put(id, docEles);
				}
				docEles.add(docEle);
			}
		}
		return idDocs;
	}

	public static Document fileToDocument(String filename) {
		if (filename == null)
			throw new NullPointerException();
		Document result = null;
		DocumentBuilderFactory dbf = DocumentBuilderFactory.newInstance();
		dbf.setNamespaceAware(true);
		try {
			DocumentBuilder db = dbf.newDocumentBuilder();
			result = db.parse(filename);
		} catch (IOException ioException) {
			ioException.printStackTrace();
			System.err.println("IO exception converting Document to File: " + filename);
			return null;
		} catch (SAXException saxException) {
			saxException.printStackTrace();
			System.err.println("Transformer Configuration exception converting Document to File: " + filename);
			return null;
		} catch (ParserConfigurationException parserConfigurationException) {
			parserConfigurationException.printStackTrace();
			System.err.println("Transformer Configuration exception converting Document to File: " + filename);
			return null;
		} catch (Exception e) {
			e.printStackTrace();
			return null;
		}
		return result;
	}

	private class PointComparator implements Comparator<Point> {

		@Override
		public int compare(Point o1, Point o2) {
			int startDif = o1.x - o2.x;
			return startDif == 0 ? o1.y - o2.y : startDif;
		}

	}
}
