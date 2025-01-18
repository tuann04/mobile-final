from tavily import TavilyClient
from dotenv import load_dotenv
import os
from typing import Dict

class SearchEngine(object):
    base_reponse = f"""
Search results:
{{results}}
"""
    single_result = f"""
{{ith}})
    Titlle: {{title}}
    Reference: {{url}}
    Content: {{content}}
    Relevance score: {{score}}
"""
    def __init__(self) -> None:
        load_dotenv()
        self.client = TavilyClient(api_key= os.environ["TAVILY_KEY"])

    def search(self, query:str)->Dict[str,str]:
        """
        Search method for finding information
        Args:
            - query (str): input query for searching
        Returns:
            - a dictionary with two keys
                - `query`: contains origial query search
                - `result`: a string search results with many results, each 
        contains `Title`, `Reference`, `Content`, `Relevance score`
        """
        response = self.client.search(query= query)
        search_results = response['results']
        
        formatted_result = "".join([SearchEngine.single_result.format(ith = ith+1, **_result) 
                            for ith, _result in enumerate(search_results)
                            ])
        return {
            'query': query,
            'result': SearchEngine.base_reponse.format(results = formatted_result)
        }