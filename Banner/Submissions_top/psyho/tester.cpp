#include "main.cpp"

VS readFile(string fn, bool dropFirstRow = false) {
	const int MAX_LINE = 100000000;
	FILE *f = fopen(fn.c_str(), "r");
	VS rv;
	while (!feof(f)) {
		static char line[MAX_LINE];
		line[0] = 0;
		fgets(line, MAX_LINE, f);
		int n = strlen(line);
		while (n && (line[n-1] == '\n' || line[n-1] == '\r')) line[--n] = 0;
		if (n == 0) continue;
		if (dropFirstRow) {
			dropFirstRow = false;
			continue;
		}
		rv.PB(line);
	}
	rv.shrink_to_fit();
	return rv;
}

struct Annotation {
	int userid;
	int id;
	int offset;
	int len;
	string text;
	
	bool overlaps(Annotation &a) {
		if (id != a.id) return false;
		return max(offset, a.offset) < min(offset + len, a.offset + a.len);
	}
};

bool operator < (const Annotation &a, const Annotation &b) { 
	if (a.userid != b.userid) return a.userid < b.userid;
	if (a.id != b.id) return a.id < b.id;
	if (a.offset != b.offset) return a.offset < b.offset;
	if (a.len != b.len) return a.len < b.len;
	return a.text < b.text;
}

bool operator == (const Annotation &a, const Annotation &b) { 
	return a.userid == b.userid && a.id == b.id && a.offset == b.offset && a.len == b.len;
}

ostream& operator<<(ostream &os, Annotation &a) {os << "(" << a.userid << "," << a.id << "," << a.offset << "," << a.len << "," << a.text << ")"; return os;}


struct Passage {
	string text;
	string type;
	int offset;
	VC<Annotation> anns;
};

struct Text {
	int id = -1;
	int voters = -1;
	string text = "";
	VC<Annotation> anns;
	VC<Passage> pass;
};

INLINE bool cmpr(string &s, int p, string &r) {
	if (p+r.S>=s.S) return false;
	REP(i, r.S) if (!(s[p+i] == r[i] || s[p+i] == ' ' && r[i] == '-' || s[p+i] == '-' && r[i] == ' ' && tolower(s[p+i]) == tolower(r[i]) && i == 0 && (p == 0 || p >= 2 && s[p-2] == '.'))) return false;
	if (p && isalnum(s[p-1])) return false;
	if (p + r.S < s.S && isalnum(s[p+r.S])) return false;	
	return true;
}

INLINE bool cmp(string &s, int p, string r) {
	if (p+r.S>=s.S) return false;
	REP(i, r.S) if (s[p+i] != r[i]) return false;
	return true;
}


string extract(string &s, int &pos, string start, string end) {
	while (!cmp(s, pos, start)) pos++;
	pos += start.S;
	
	string rv = "";
	while (!cmp(s, pos, end)) rv += s[pos++];
	pos += end.S;
	return rv;
}

VC<Text> parseFile(string fn) {
	int pos = 0;
	string data = readFile(fn, false)[0];
	
	string ndata = "";
	REP(i, data.S) {
		if (cmp(data, i, "&lt;")) {
			ndata += "<";
			i += 3;
		} else if (cmp(data, i, "&gt;")) {
			ndata += ">";
			i += 3;
		} else if (cmp(data, i, "&amp;")) {
			ndata += "&";
			i += 4;
		} else {
			ndata += data[i];
		}
	}
	data = ndata;
	
	
	VC<Text> rv;
	Text text;
	int lastOffset = -1;
	string lastType = "!@##@!";
	int lastVoters = -1;
	while (true) {
		if (pos >= data.S) break;
	
		if (cmp(data, pos, "</document>")) {
			assert(text.id != -1);
			// assert(lastVoters != -1);
			rv.PB(text);
			text.id = -1;
			text.text = "";
			text.voters = lastVoters;
			text.anns.clear();
			text.pass.clear();
			lastOffset = -1;
			lastVoters = -1;
			pos++;
		} else if (cmp(data, pos, "<infon key=\"n_annotators\">")) {
			assert(lastVoters == -1);
			lastVoters = atoi(extract(data, pos, "<infon key=\"n_annotators\">", "</infon>").c_str());
		} else if (cmp(data, pos, "<infon key=\"type\">")) {
			// assert(lastType == "!@##@!");
			lastType = extract(data, pos, "<infon key=\"type\">", "</infon>");
		} else if (cmp(data, pos, "<id>")) {
			text.id = atoi(extract(data, pos, "<id>", "</id>").c_str());
		} else if (cmp(data, pos, "<annotation")) {
			Annotation ann;
			ann.id = text.id;
			ann.userid = atoi(extract(data, pos, "<infon key=\"annotator_id\">", "</infon>").c_str());
			ann.offset = atoi(extract(data, pos, "<location offset=\"", "\"").c_str());
			ann.len = atoi(extract(data, pos, "length=\"", "\"").c_str());
			ann.text = extract(data, pos, "<text>", "</text>");
			text.anns.PB(ann);
			text.pass[text.pass.S-1].anns.PB(ann);
		} else if (cmp(data, pos, "<offset>")) {
			// assert(lastOffset == -1);
			lastOffset = atoi(extract(data, pos, "<offset>", "</offset>").c_str());
		} else if (cmp(data, pos, "<text>")) {
			assert(lastOffset != -1);
			assert(lastType != "!@##@!");
			string s = extract(data, pos, "<text>", "</text>");
			while (text.text.S < lastOffset) text.text += "|";
			text.text += s;
			// if (pos < 3000) {DB(lastOffset); DB(s); DB(text.text.S);}
			Passage pass;
			pass.text = s;
			pass.offset = lastOffset;
			pass.type = lastType;
			pass.anns.clear();
			text.pass.PB(pass);
			lastOffset = -1;
			lastType = "!@##@!";
		} else {
			pos++;
		}
	}
	
	return rv;
}

string escape(string &s) {
	string rv = "";
	REP(i, s.S) {
		if (s[i] == '<') {
			rv += "&lt;";
		} else if (s[i] == '>') {
			rv += "&gt;";
		} else if (s[i] == '&') {
			rv += "&amp;";
		} else {
			rv += s[i];
		}
	}
	return rv;
}

void save(VC<Text> &data, string fn) {
	ofstream fs(fn.c_str());
	fs << "<collection>";
	int pos = 0;
	
	int id = 0;
	for (Text &text : data) {
		fs << "<document>";
		fs << "<id>" << text.id << "</id>";
		for (Passage &pass : text.pass) {
			fs << "<passage>";
			fs << "<infon key=\"type\">" << pass.type << "</infon>";
			fs << "<offset>" << pass.offset << "</offset>";
			fs << "<text>" << escape(pass.text) << "</text>";
			for (Annotation &ann : pass.anns) {
				fs << "<annotation id=\"" << id++ << "\">";
				fs << "<infon key=\"annotator_id\">" << ann.userid << "</infon>";
				fs << "<infon key=\"type\">Disease</infon>";
				fs << "<location offset=\"" << ann.offset << "\" length=\"" << ann.len << "\"/>";
				fs << "<text>" << escape(ann.text) << "</text>";
				fs << "</annotation>";
			}
			fs << "</passage>";
		}
		fs << "</document>";
	}
	fs << "</collection>";
	fs.close();
}

VC<Text> loadResults() {
	auto data = parseFile("test_file.xml");
	
	string s = readFile("res.cpp")[0];
	s = s.substr(1, s.S - 3);
	VI v;
	VS vs = splt(s, ',');
	for (string &r : vs) v.PB(atoi(r.c_str()));
	
	for (int i = 0; i < v.S; i += 3) {
		Annotation ann;
		ann.userid = 6;
		ann.id = v[i+0];
		ann.offset = v[i+1];
		ann.len = v[i+2];
		if (ann.offset + ann.len >= data[v[i]].text.S) {
			cout << ann << endl;
			DB(data[v[i]].text.S);
		}
		ann.text = data[v[i]].text.substr(ann.offset, ann.len);
		data[v[i]].anns.PB(ann);
	}
	
	return data;
}

void saveResults(VC<Text> &data, string fn) {
	VI v;
	for (Text &text : data) for (Annotation &ann : text.anns) v.PB(text.id), v.PB(ann.offset), v.PB(ann.len);
	ofstream fs(fn.c_str());
	fs << v << ";" << endl;
	fs.close();
}

void saveHTML(VC<Text> &data, string fn) {
	ofstream fs(fn.c_str());
	for (Text &text : data) {
		sort(ALL(text.anns));
		fs << "<p><tt><b>";
		REP(i, text.text.S) {
			bool inside = false;
			for (auto &ann : text.anns) inside |= i >= ann.offset && i < ann.offset + ann.len;
			if (inside) fs << "<font color=\"red\">";
			fs << text.text[i];
			if (inside) fs << "</font>";
		}
		fs << "</b></tt></p>" << endl;
	}
	fs.close();
}

map<string, double> pars;

double getpar(string name, double def = -1e9) {
	if (pars.count(name) == 0 && def < -1e8) {
		cout << "Error: Parameter " << name << " not defined but requested" << endl;
		exit(1);
	}
	return pars.count(name) ? pars[name] : def;
}

string showContext(Text &text, Annotation &ann) {
	string rv = "";
	rv += text.text.substr(max(0, ann.offset - 10), min(10, ann.offset));
	rv += "#";
	rv += ann.text;
	rv += "#";
	rv += text.text.substr(ann.offset + ann.len, min(10, (int)text.text.S - ann.offset - ann.len));
	return rv;
}

int main(int argc, char **argv) {
	string cmdArgs = "";
	FOR(i, 1, argc) {
		if (i>1) cmdArgs += " ";
		cmdArgs += string(argv[i]);
	}
	
	
	FOR(i, 1, argc) {
		string cmd = argv[i];
		if (cmd[0] == '-') {
			string s = cmd.substr(1);
			double value = (i+1>=argc || argv[i+1][0] == '-') ? 1 : atof(argv[++i]);
			pars[s] = value;
		}
	}
	
	VS allowedPar = {"mr", "mv", "noover", "anal", "output", "tperc", "showusers", "remix", "seed"};
	for (auto &p : pars) if (find(ALL(allowedPar), p.X) == allowedPar.end()) {
		cout << "Error: Unrecognized Parameter: " << p.X << endl;
		exit(1);
	}
	
	VS files = {"expert1_bioc.xml", "expert_processed.xml", "mturk1_bioc.xml", "mturk2_bioc.xml", "test_file.xml"};
	if (getpar("output", 0)) {
		auto data = loadResults();
		saveHTML(data, "res.html");
		exit(0);
	}
	
	if (getpar("remix", 0)) {
		int seed = int(getpar("seed", 0));
		int MAXID = 2300;
		int sols = int(getpar("remix"));
		int mv = int(getpar("mv", sols / 2 + 1));
		set<PII> res[MAXID][sols];
		
		REP(i, sols) {
			string s = readFile("res" + i2s(i+1) + ".cpp")[0];
			s = s.substr(1, s.S - 3);
			VI v;
			VS vs = splt(s, ',');
			for (string &r : vs) v.PB(atoi(r.c_str()));
			REP(j,v.S/3) res[v[j*3]][i].insert(MP(v[j*3+1],v[j*3+2]));
		}
		
		VI rv;		
		if (seed == 0) {
			REP(i, MAXID) {
				set<PII> all;
				REP(j, sols) for (PII p : res[i][j]) all.insert(p);
				for (PII p : all) {
					int cnt = 0;
					REP(j, sols) cnt += res[i][j].count(p) > 0;
					if (cnt >= mv) rv.PB(i), rv.PB(p.X), rv.PB(p.Y);
				}
			}
		} else {
			RNG rng(seed);
			REP(i, MAXID) {
				int s = rng.next(sols);
				for (PII p : res[i][s]) rv.PB(i), rv.PB(p.X), rv.PB(p.Y);
			}
		}
		
		ofstream fs("res.cpp");
		fs << rv << ";" << endl;
		fs << "//Args: " << cmdArgs << endl;
		fs.close();
		exit(0);
	}
	
	if (getpar("anal", 0)) {
		auto data = getpar("anal") == 1 ? loadResults() : parseFile("expert1_bioc.xml");
		for (Text &text : data) {
			for (Annotation &ann : text.anns) {
				bool important = false;
				// important |= ann.text.find('(') != string::npos || ann.text.find(')') != string::npos;
				// important |= text.text.S > ann.offset + ann.len && text.text[ann.offset + ann.len] == '-';
				// important |= find(ALL(ann.text), ',') != ann.text.end();
				// important |= text.text.S > ann.offset + ann.len && isalnum(text.text[ann.offset + ann.len]);
				important |= ann.offset && isalnum(text.text[ann.offset-1]);
				if (important) cout << showContext(text, ann) << endl;
			}
		}
		exit(0);
	}
	
	auto expertData = parseFile("expert1_bioc.xml");
	auto procData  = parseFile("expert_processed.xml");
	auto turkDataA = parseFile("mturk1_bioc.xml");
	auto turkDataB = parseFile("mturk2_bioc.xml");
	
	map<int, int> mapFP;
	map<int, int> mapFN;
	map<int, int> mapTP;
	map<int, int> mapTexts;
	set<int> allUsers;
	REP(i, turkDataA.S) {
		int id = -1;
		REP(j, expertData.S) if (expertData[j].id == turkDataA[i].id) id = j;
		if (id == -1) continue;
		Text &expertText = expertData[id];
	
		map<int, int> found;
		set<int> users;
		for (auto ann : turkDataA[i].anns) {
			int user = ann.userid;
			users.insert(user);
			allUsers.insert(user);
			auto a = ann;
			a.userid = 6;
			if (find(ALL(expertText.anns), a) != expertText.anns.end()) {
				mapTP[user]++;
				found[user]++;
			} else {
				mapFP[user]++;
			}
		}
		
		for (int user : users) {
			mapTexts[user]++;
			mapFN[user] += expertText.anns.S - found[user];
		}
	}
	
	for (Text &text : turkDataB) {
		set<int> users;
		for (auto &ann : text.anns) users.insert(ann.userid);
		for (int user : users) {
			mapTexts[user]++;
			allUsers.insert(user);
		}
	}
	
	map<int, double> userValue;
	double sum = 0;
	double no = 0;
	for (int user : allUsers) {
		userValue[user] = sqrt(mapTexts[user]);
		double fscore = .764304;
		if (mapTP[user] || mapFP[user]) {
			double precision = 1.0 * mapTP[user] / (mapTP[user] + mapFP[user]);
			double recall = 1.0 * mapTP[user] / (mapTP[user] + mapFN[user]);
			// userValue[user] += 4 * ((2 * precision * recall / (precision + recall)) - 0.8);
			// userValue[user] = max(userValue[user], 0.1);
			fscore = 2 * precision * recall / (precision + recall);
			// userValue[user] = max(userValue[user], 0.1);
		}
		userValue[user] = fscore;
	}
	
	if (getpar("showusers", 0)) {
		for (int user : allUsers) {
			double precision = 1.0 * mapTP[user] / (mapTP[user] + mapFP[user]);
			double recall = 1.0 * mapTP[user] / (mapTP[user] + mapFN[user]);
			printf("User: %d  T: %d  TP: %d  FP: %d  FN: %d  R: %lf  F-S: %lf  Value: %lf\n", user, mapTexts[user], mapTP[user], mapFP[user], mapFN[user], precision, 2 * precision * recall / (precision + recall), userValue[user]); 
		}
	}
	
	
	// exit(0);
	
	VD textValues;
	for (Text text : turkDataB) {
		set<int> users;
		for (auto &ann : text.anns) users.insert(ann.userid);
		double textValue = 0;
		for (int user : users) textValue += userValue[user];
		textValues.PB(textValue);
	}
	sort(ALL(textValues));
	
	VC<Text> finalData(ALL(expertData));
	const double minRatio = getpar("mr");
	bool noOverlap = getpar("noover", 0) == 1;
	VI total(1000);
	int added = 0;
	
	DB(textValues[int(textValues.S * 0.1)]);
	DB(textValues[int(textValues.S * 0.25)]);
	DB(textValues[int(textValues.S * 0.5)]);
	DB(textValues[int(textValues.S * 0.75)]);
	DB(textValues[int(textValues.S * 0.9)]);
	
	for (Text text : turkDataB) {
		Text ntext = text;
		for (Passage &pass : ntext.pass) pass.anns.clear();
		ntext.anns.clear();
		
		set<int> users;
		for (auto &ann : text.anns) users.insert(ann.userid);
		double textValue = 0;
		for (int user : users) textValue += userValue[user];
		if (textValue < textValues[int(textValues.S * (1 - getpar("tperc")))]) continue;
		
		
		REP(i, text.pass.S) {
			map<Annotation, double> annMap;
			set<Annotation> annSet(ALL(text.pass[i].anns));
			for (auto ann : annSet) {
				bool bad = false;
				REP(j, ann.text.S) bad |= cmp(ann.text, j, "?");
				if (bad) continue;
			
				Annotation annCopy = ann;
				annCopy.userid = 6;
				annMap[annCopy] += userValue[ann.userid];
			}
			
			VC<pair<Annotation, double>> vp(ALL(annMap));
			sort(vp.begin(), vp.end(), [](const pair<Annotation, double> &a, const pair<Annotation, double> &b) -> bool {return a.Y > b.Y;});
			for (auto &p : vp) {
				// if (p.Y < text.voters * minRatio) break;
				if (p.Y < textValue * minRatio) break;
			
				bool ok = true;
				if (noOverlap) for (auto &a : ntext.pass[i].anns) if (a.overlaps(p.X)) ok = false;
				if (ok) {
					ntext.pass[i].anns.PB(p.X);
					ntext.anns.PB(p.X);
				}
			}
		}
		
		total[text.voters]++;
		if (ntext.anns.S && text.voters >= getpar("mv")) {
			added += ntext.anns.S;
			finalData.PB(ntext);
		}
	}
	
	DB(added);	
	REP(i, total.S) if (total[i]) cout << i << ' ' << total[i] << endl;
	DB(finalData.S);
	
	save(finalData, "data/ncbi_train_bioc.xml");
}
