package banner.features;

import java.io.BufferedReader;
import java.io.FileNotFoundException;
import java.io.FileReader;
import java.io.IOException;
import java.util.HashMap;
import java.util.Map;

import cc.mallet.pipe.Pipe;
import cc.mallet.types.Instance;
import cc.mallet.types.Token;
import cc.mallet.types.TokenSequence;



public class BrownClusters extends Pipe {

	/**
	 * 
	 */
	private static final long serialVersionUID = 1L;
	private Map<String,String> brownMapping1000 = new HashMap<String,String>();
	private Map<String,String> brownMapping500 = new HashMap<String,String>();

	
	public BrownClusters(String filename1000, String filename500) 
	{
		System.out.println( "Loading brown clusters" );
		try (BufferedReader br = new BufferedReader(new FileReader(filename1000))) {
		    String line;
		    while ((line = br.readLine()) != null) {
		       // process the line.
		    	String[] brown_cluster_info = line.split("\\s+");
		    	String brownCluster = brown_cluster_info[0];
		    	String wordForm = brown_cluster_info[1];
		    	brownMapping1000.put(wordForm, brownCluster);
		    }
		} catch (FileNotFoundException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		} catch (IOException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
		try (BufferedReader br = new BufferedReader(new FileReader(filename500))) {
		    String line;
		    while ((line = br.readLine()) != null) {
		       // process the line.
		    	String[] brown_cluster_info = line.split("\\s+");
		    	String brownCluster = brown_cluster_info[0];
		    	String wordForm = brown_cluster_info[1];
		    	brownMapping500.put(wordForm, brownCluster);
		    }
		} catch (FileNotFoundException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		} catch (IOException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
		System.out.println( "Finished loading brown clusters" );
	}
	
	public String returnBrown1000Cluster(String wordForm)
	{
		if ( brownMapping1000.containsKey(wordForm) )
		{
			return brownMapping1000.get( wordForm  );
		}
		
		return "";
	}
	public String returnBrown500Cluster(String wordForm)
	{
		if ( brownMapping500.containsKey(wordForm) )
		{
			return brownMapping500.get( wordForm  );
		}
		
		return "";
	}
	
	
	@Override
	public Instance pipe(Instance carrier) {
		TokenSequence tokens = (TokenSequence) carrier.getData();
		for (int i = 0 ; i < tokens.size(); i++) {
			Token token = tokens.get(i);
			String word = token.getText().toLowerCase();
			String brownCluster = returnBrown1000Cluster(word);
			if (brownCluster.length() > 0)
			{
				token.setFeatureValue("brown_1000_" + brownCluster, 1.0);
			}
			/*
			String brown500Cluster = returnBrown500Cluster(word);
			if (brown500Cluster.length() > 0)
			{
				token.setFeatureValue("brown_500_" + brown500Cluster, 1.0);
			}*/
			//adding brown cluster
		}
		return carrier;
	}
	
	public static void main(String[] args)
	{
		BrownClusters _cluster = new BrownClusters("/home/egor/PycharmProjects/pyGeneCRF/word_vectors/brown_1000c_26M_paths",
				"/home/egor/PycharmProjects/pyGeneCRF/word_vectors/brown_500c_paths");
	}
	
	
}
