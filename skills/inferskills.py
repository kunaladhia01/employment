import numpy as np
import json


class InferSkills:
  def __init__(self):
    self.vals = {}
    with open('skillsets_labels.tsv', 'r') as f:
      for line in f:
        items = line.split('\t')
        k = items[1]
        v = set(items[2].replace('\n', '').lower().split(', '))
        self.vals[k] = v
  
  def render_scores(self, data, scores, keywords):
    for i in data:
      for k in self.vals.keys():
        for v in self.vals[k]:
          if len(v.split(" ")) == 1:
            if v in i.split(" "):
              scores[k] += 1
              if v in keywords.keys():
                keywords[v] += 1
              else:
                keywords[v] = 1
          else:
            if v in i:
              scores[k] += 1
              if v in keywords.keys():
                keywords[v] += 1
              else:
                keywords[v] = 1
  
  def infer_exp(self, p, e, return_scores = False):
    if "role" not in e.keys() or e["role"] == None:
      if return_scores:
        return [], []
      return []
    # Extract information from relevant fields
    data = []
    for k in e["role"].keys():
      if e["role"][k]:
        if type(e["role"][k]) == list:
          for item in e["role"][k]:
            if type(item) == str:
              data.append(item.lower())
        elif type(e["role"][k]) == str:
          data.append(e["role"][k].lower())
    if e["description"]:
      data.append(e["description"].lower())
    if e["industry"]:
      data.append(e["industry"].lower())
    
    scores = {}
    keywords = {}

    for k in self.vals.keys():
      scores[k] = 0

    self.render_scores(data, scores, keywords)
    
    if return_scores:
      return scores, keywords

    ret = []
    sorted_scores = sorted(keywords.items(), key=lambda item: item[1])
    for i in sorted_scores:
      if i[1]:
        ret.append(i[0])

    return ret

  def infer_profile(self, p):
    if p["raw_skills"]:
      return [p["raw_skills"]]
    total_scores = {}
    total_keywords = {}
    for k in self.vals.keys():
      total_scores[k] = 0
    for e in p["experience"]:
      categories, keywords = self.infer_exp(p, e, True)
      if categories:
        for k in categories.keys():
          total_scores[k] += categories[k]
      if keywords:
        for k in keywords.keys():
          if k in total_keywords.keys():
            total_keywords[k] += keywords[k]
          else:
            total_keywords[k] = keywords[k]
    sorted_scores = sorted(total_keywords.items(), key=lambda item: item[1])
    ret = []

    for i in sorted_scores:
      if i[1]:
        ret.append(i[0])

    return ret


  def load_sample_profile(self):
    # Extract information from relevent points of interest
    with open("text.txt", 'r') as f:
      line = f.readline()
      return json.loads(line)

s = InferSkills()
profile = s.load_sample_profile()
print(s.infer_profile(profile))
for exp in profile.get('experience', []):
  print(s.infer_exp(profile, exp))