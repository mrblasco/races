import java.io.*;
import java.util.Arrays;
import java.util.*;
import java.io.BufferedReader;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.io.PrintWriter;
import java.security.SecureRandom;
import java.text.*;

public class BannerAnnotate
{
    private final int TIME_LIMIT = 5*60 * 1000; // 5 minutes
    public static long seed = 1;

    class Mention {
        int ID, offset, len;
        public boolean overlaps(Mention mention2)
        {
            return ID==mention2.ID && offset+len > mention2.offset && offset < mention2.offset+mention2.len;
        }
        @Override
        public boolean equals(Object obj)
        {
            if (this == obj)
                return true;
            if (obj == null)
                return false;
            if (getClass() != obj.getClass())
                return false;
            final Mention other = (Mention)obj;
            if (ID!=other.ID)
                return false;
            if (offset!=other.offset)
                return false;
            if (len!=other.len)
                return false;
            return true;
        }

        public int compareTo(Mention mention2)
        {
            Integer compare = offset - mention2.offset;
            if (compare != 0)
                return compare;
            compare = offset+len - (mention2.offset+mention2.len);
            if (compare != 0)
                return compare;
            return ID - (mention2.ID);
        }
    }

    public String checkData(String test)
    {
        return "";
    }

    public String displayTestCase(String s)
    {
        return "SEED="+s;
    }

    public double runTest(LongTest lt)
    {
        try {

            LongTest.WriterCache cache = lt.newCacheInstance();
            cache.setMinimalVersion(1);

            long seed = Long.parseLong(lt.getTest());


            // load linking file
            int id_set[] = new int[5000];
            {
//                BufferedReader br = new BufferedReader(new FileReader("data_link.csv"));
                String[] brdt = (String[])cache.get("data_link.csv");
                if (brdt==null)
                {
                    lt.addFatalError("ERROR: data_link.csv not cached");
                    return -1.0;
                }
                int bridx = 0;
                while (bridx<brdt.length)
                {
                    String s = brdt[bridx++];//br.readLine();
                    if (s==null) break;
                    String[] items = s.split(",");
                    if (items.length>1)
                    {
                        int ID = Integer.parseInt(items[0]);
                        int st = Integer.parseInt(items[1]);
                        if (ID<130 && st==2) st = 4;
                        id_set[ID] = st;
                    }
                }
               // br.close();
            }
            List<Mention> gtfMentions = new ArrayList<Mention>();
            // load gtf file
            {
                //BufferedReader br = new BufferedReader(new FileReader("gtf.csv"));
                String[] brdt = (String[])cache.get("gtf.csv");
                if (brdt==null)
                {
                    lt.addFatalError("ERROR: gtf.csv not cached");
                    return -1.0;
                }
                int bridx = 0;
                while (bridx<brdt.length)
                {
                    String s = brdt[bridx++];//br.readLine();
                    if (s==null) break;
                    String[] items = s.split(",");
                    if (items.length>2)
                    {
                        Mention m = new Mention();
                        m.ID = Integer.parseInt(items[0]);
                        int st = id_set[m.ID];
                        if (st==seed)
                        {
                            m.offset = Integer.parseInt(items[1]);
                            m.len = Integer.parseInt(items[2]);
                            gtfMentions.add(m);
                        }
                    }
                }
               // br.close();
            }

            // get answer
            lt.setTimeLimit(TIME_LIMIT);
            lt.annotate();
            if (!lt.getStatus())
            {
                lt.addFatalError("ERROR: Error during the call to annotate method.");
                return -1.0;
            }
            int T = lt.getTime();
            int[] answer = lt.getResult_annotate();
            if (!lt.getStatus())
            {
                lt.addFatalError("ERROR: Error during the call to annotate method.");
                return -1.0;
            }
            if (T > TIME_LIMIT) {
                lt.addFatalError("ERROR: Time limit during the call to annotate method.");
                return -1.0;
            }

            if ( (answer.length%3) != 0 ) {
                lt.addFatalError("ERROR: return size not a multiple of 3.");
                return -1.0;
            }

            List<Mention> answerMentions = new ArrayList<Mention>();
            for (int i=0;i<answer.length;i+=3) {
                Mention m = new Mention();
                m.ID = answer[i];
                if (m.ID<0 || m.ID>3000) {
                    lt.addFatalError("ERROR: ID out of range.");
                    return -1.0;
                }
                int st = id_set[m.ID];
                if (st==seed) {
                    m.offset = answer[i+1];
                    m.len = answer[i+2];
                    answerMentions.add(m);
                }
            }

            // score
            int tp = 0;
            int fp = 0;
            int fn = 0;
            Set<Mention> mentionsNotFound = new HashSet<Mention>(gtfMentions);
            for (Mention mFound : answerMentions) {
                boolean found = false;
                if (mentionsNotFound.contains(mFound)) {
                    mentionsNotFound.remove(mFound);
                    found = true;
                    tp++;
                } else if (gtfMentions.contains(mFound)) {
                    found = true;
                    for (Mention mentionRequired : new HashSet<Mention>(mentionsNotFound)) {
                        if (mFound.overlaps(mentionRequired)) {
                            mentionsNotFound.remove(mentionRequired);
                            tp++;
                        }
                    }
                }
                if (!found) {
                    fp++;
                }
            }
            for (Mention mentionNotFound : mentionsNotFound) {
                fn++;
            }
            lt.addFatalError("tp = " + tp + "\n");
            lt.addFatalError("fp = " + fp + "\n");
            lt.addFatalError("fn = " + fn + "\n");
            double precision = (double) tp / (tp + fp);
            double recall = (double) tp / (tp + fn);
            lt.addFatalError("precision = " + precision + "\n");
            lt.addFatalError("recall = " + recall + "\n");
            double fmeasure = 0;
            if (precision + recall > 1e-10) {
                fmeasure = 2.0 * precision * recall / (precision + recall);
            }
            double score = 1000000.0 * fmeasure;
			saveReturnValue(lt, score);
			if (score != score) {
				// This is a check to avoid the queue getting fouled up,
				// as a NaN score hangs the queue for that competitor.
				lt.addFatalError("NaN value detected");
				return -1.0;
			}
			if (seed == 1) {
				// We will always run the system test,
				// but we want to send back a score that gets ignored.
				return -1.0 * score - 1.0;
			}
            return score;
        }
        catch (Exception e)
        {
            lt.addFatalError("RunTest Exception: " + e.getMessage() + "\n");

            StringWriter sw = new StringWriter();
            PrintWriter pw = new PrintWriter(sw);
            e.printStackTrace(pw);
            lt.addFatalError(sw.toString() + "\n");

            return -1.0;
        }
    }

    void saveReturnValue(LongTest lt, double score) {
        String path = lt.getPath();
		String test = lt.getTest();
		SimpleDateFormat sdfDate = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");
		Date now = new Date();
		String strDate = sdfDate.format(now);
        String dir = "/home/farm/datadump/BannerTests";
        if (!new File(dir).exists()) new File(dir).mkdirs();
        try {
            PrintWriter pw = new PrintWriter(new FileWriter(dir + "/scores.csv", true));
			pw.println(strDate + "," + path + "," + test + "," + score);
            pw.flush();
            pw.close();
        } catch (Exception e) {
            lt.addFatalError("Error recording score.");
        }
    }
	
    public double[] score(double[][] d)
    {
        double[] rv = new double[d.length];
        int num = d[0].length;
		if (num == 3) num = 2; // Ignore the system test which returns a negative value;
        for (int i = 0; i < rv.length; i++)
        {
            rv[i] = 0.0;
        }
        for (int i = 0; i < d.length; i++) {
            for (int j = 0; j < d[i].length; j++)
            {
                if (d[i][j] > 0)
                {
                    rv[i] += d[i][j];
                }
            }
        }
        for (int i = 0; i < d.length; i++) {
            rv[i] /= num;
        }
        return rv;
    }
}

