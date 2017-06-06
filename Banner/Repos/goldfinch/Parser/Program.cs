using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Xml;
using System.Xml.Linq;

namespace Parser
{
    using System.IO;
    using System.Net.Mail;

    public class Annotation
    {
        public int offset;
        public int length;
        public string annotator_id;
    }

    class Program
    {
        private const string PATH_MTURK1 = @"D:\Dropbox\git\BANNER\training_data\mturk1_bioc.xml";
        private const string PATH_MTURK2 = @"D:\Dropbox\git\BANNER\training_data\mturk2_bioc.xml";
        private const string PATH_EXPERT1 = @"D:\Dropbox\git\BANNER\training_data\expert1_bioc.xml";

        private const string SAVE_MTURK2 = @"D:\Dropbox\code\BANNER\data\mturk2_1.xml";


        private static void Main(string[] args)
        {
            var doc = XDocument.Load(PATH_MTURK1);
            var collection = doc.Elements().First(elem => elem.Name == "collection");
            var abstracts = collection.Elements().Where(elem => elem.Name == "document").ToList();

            var absT1 = abstracts.ToDictionary(a => a.Element("id").Value);

            doc = XDocument.Load(PATH_EXPERT1);
            collection = doc.Elements().First(elem => elem.Name == "collection");
            var absE1 = collection.Elements().Where(elem => elem.Name == "document").ToDictionary(a => a.Element("id").Value);

            Dictionary<string, int> attempts = new Dictionary<string, int>();
            Dictionary<string, int> hits = new Dictionary<string, int>();
            Dictionary<string, int> opportunities = new Dictionary<string, int>();

            Dictionary<string, int> fullMisses = new Dictionary<string, int>();

            foreach (var dt1 in absT1)
            {
                if (!absE1.ContainsKey(dt1.Key))
                    continue;
                var de1 = absE1[dt1.Key];

                var pe1s = de1.Elements("passage");

                var annotElem = dt1.Value.Elements().First(
                         elem => elem.Attribute("key") != null && elem.Attribute("key").Value == "annotator_ids");
                var anIds = annotElem.Value.Split(
                    new char[] { ',', '[', ']', ' ' },
                    StringSplitOptions.RemoveEmptyEntries);


                foreach (var pt1 in dt1.Value.Elements("passage"))
                {
                    var offset = pt1.Element("offset").Value;
                    var pe1 = pe1s.FirstOrDefault(elem => elem.Element("offset").Value == offset);
                    if (pe1 == null)
                    {
                        Console.WriteLine("no passage!");
                        continue;
                    }

                    var ae1s = pe1.Elements("annotation").Select(
                        elem =>
                            {
                                var loc = elem.Element("location");
                                return new Annotation()
                                           {
                                               length = int.Parse(loc.Attribute("length").Value),
                                               offset = int.Parse(loc.Attribute("offset").Value)
                                           };
                            }).ToList();

                    foreach (var id in anIds)
                    {
                        if (opportunities.ContainsKey(id))
                            opportunities[id] += ae1s.Count;
                        else
                            opportunities.Add(id, ae1s.Count);
                    }


                    foreach (var at1 in pt1.Elements("annotation"))
                    {
                        var annotatore1 =
                            at1.Elements()
                                .First(
                                    elem =>
                                    elem.Attribute("key") != null && elem.Attribute("key").Value == "annotator_id")
                                .Value;
                        var text = at1.Element("text").Value;
                        var loc = at1.Element("location");
                        var os = int.Parse(loc.Attribute("offset").Value);
                        var le = int.Parse(loc.Attribute("length").Value);
                        bool fullMiss = true;
                        foreach (var ae1 in ae1s)
                        {
                            if (ae1.offset == os && ae1.length == le)
                            {
                                if (hits.ContainsKey(annotatore1))
                                    hits[annotatore1]++;
                                else
                                    hits.Add(annotatore1, 1);
                                fullMiss = false;
                            }
                            if (ae1.offset < os && ae1.offset + ae1.length > os
                                || ae1.offset < os + le && ae1.offset + ae1.length > os + le)
                                fullMiss = false;
                        }

                        if (fullMiss)
                        {
                            if (fullMisses.ContainsKey(text))
                                fullMisses[text]++;
                            else
                                fullMisses.Add(text, 1);
                        }

                        if (attempts.ContainsKey(annotatore1))
                            attempts[annotatore1]++;
                        else
                            attempts.Add(annotatore1, 1);
                    }
                }
            }

            Dictionary<string, double> precision = new Dictionary<string, double>();
            foreach (var at in attempts)
            {
                int h = 0;
                if (hits.ContainsKey(at.Key))
                {
                    h = hits[at.Key];
                }
                precision[at.Key] = (double)h / at.Value;
            }

            foreach (var p in precision.OrderByDescending(p=>p.Value))
            {
                Console.WriteLine(p.Key + "    " + attempts[p.Key] + "    " +  p.Value + "    " + (double)hits[p.Key]/opportunities[p.Key]);
            }
            
            var tfm = fullMisses.OrderByDescending(fm=>fm.Value).ToList();
            Console.WriteLine(tfm.Count);



            doc = XDocument.Load(PATH_MTURK2);
            collection = doc.Elements().First(elem => elem.Name == "collection");
            var absT2 = collection.Elements().Where(elem => elem.Name == "document");

            int[] amap = new int[256];
            foreach (var dt2 in absT2)
            {
                var annotElem = dt2.Elements().First(
                         elem => elem.Attribute("key") != null && elem.Attribute("key").Value == "annotator_ids");
                var anIds = annotElem.Value.Split(
                    new char[] { ',', '[', ']', ' ' },
                    StringSplitOptions.RemoveEmptyEntries);

                string bestAnn = "";
                double bestPrec = 0.0;
                for (int i = 0; i < anIds.Length; i++)
                {
                    var ann = anIds[i];
                    if (precision.ContainsKey(ann) && precision[ann] > bestPrec)
                    {
                        bestAnn = ann;
                        bestPrec = precision[ann];
                    }
                }

                annotElem.SetValue("[" + 19 + "]");

                foreach (var pt2 in dt2.Elements("passage"))
                {
                    var annotations = pt2.Elements("annotation").ToList();
                    for(int i = annotations.Count -1;i>=0;i--)
                    {
                        var at2 = annotations[i];
                        var ae =
                            at2.Elements()
                                .First(
                                    elem =>
                                    elem.Attribute("key") != null && elem.Attribute("key").Value == "annotator_id");
                        var annotatore1 = ae.Value;
                        if(annotatore1 != bestAnn)
                            at2.Remove();
                        else
                        {
                            ae.SetValue("19");
                        }
                    }
                }
            }



            doc.Save(SAVE_MTURK2);

            //HashSet<int> anns = new HashSet<int>();

            //foreach (var ab in abstracts)
            //{
            //    var annotElem = ab.Elements().First(
            //        elem => elem.Attribute("key") != null && elem.Attribute("key").Value == "annotator_ids");
            //    var anIds =
            //        Array.ConvertAll(
            //            annotElem.Value.Split(new char[] { ',', '[', ']', ' ' }, StringSplitOptions.RemoveEmptyEntries),
            //            int.Parse);
            //    foreach (var id in anIds)
            //    {
            //        anns.Add(id);
            //    }
            //}



            //doc = XDocument.Load(PATH_MTURK2);
            //collection = doc.Elements().First(elem => elem.Name == "collection");
            //abstracts = collection.Elements().Where(elem => elem.Name == "document").ToList();

            //HashSet<int> anns2 = new HashSet<int>();

            //foreach (var ab in abstracts)
            //{
            //    var annotElem = ab.Elements().First(
            //        elem => elem.Attribute("key") != null && elem.Attribute("key").Value == "annotator_ids");
            //    var anIds =
            //        Array.ConvertAll(
            //            annotElem.Value.Split(new char[] { ',', '[', ']', ' ' }, StringSplitOptions.RemoveEmptyEntries),
            //            int.Parse);
            //    foreach (var id in anIds)
            //    {
            //        anns2.Add(id);
            //    }
            //}

            //Console.WriteLine(anns.Intersect(anns2).Count());
            //Console.WriteLine(anns.Except(anns2).Count());
            //Console.WriteLine(anns2.Except(anns).Count());


            //Console.WriteLine("abstracts count = " + abstracts.Count);
            //Console.WriteLine("annotators count = " + anns.Count);
        }
    }
}
