package banner.features;

import cc.mallet.pipe.Pipe;
import cc.mallet.types.Instance;
import cc.mallet.types.Token;
import cc.mallet.types.TokenSequence;



public class DictionaryFeatures extends Pipe {
	
	public DictionaryFeatures( )
	{
	}
	
	@Override
	public Instance pipe(Instance carrier) {
		TokenSequence tokens = (TokenSequence) carrier.getData();
		
		return carrier;
	}
}
