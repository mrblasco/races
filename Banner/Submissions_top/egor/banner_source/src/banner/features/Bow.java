package banner.features;

import cc.mallet.pipe.Pipe;
import cc.mallet.types.Instance;
import cc.mallet.types.Token;
import cc.mallet.types.TokenSequence;



public class Bow extends Pipe {
	
	private int _window;
	public Bow( int window)
	{
		_window = window;
	}
	
	@Override
	public Instance pipe(Instance carrier) {
		TokenSequence tokens = (TokenSequence) carrier.getData();
		for (int i = 0 ; i < tokens.size(); i++) {
			Token token = tokens.get(i);
			for (int j = Math.max(0, i - _window); j < Math.min(tokens.size(), i + _window); j++)
			{
				if (j!= i)
				{
					Token bowToken = tokens.get(j);
					String bowWord = bowToken.getText().toLowerCase();
					token.setFeatureValue("bow_" + bowWord, 1.0);
				}
			}
		}
		return carrier;
	}
}
