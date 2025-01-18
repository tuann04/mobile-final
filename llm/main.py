from src.agent import Agent

import ngrok
from fastapi import FastAPI, Request, Body
from fastapi.responses import JSONResponse
from fastapi.middleware.cors import CORSMiddleware
from typing import Annotated
from contextlib import asynccontextmanager
import asyncio
import uvicorn
from dotenv import load_dotenv
import os

@asynccontextmanager
async def lifespan(app: FastAPI):
    app.agent = Agent()
    load_dotenv()
    ngrok.set_auth_token(os.environ['NGROK_AUTH_TOKEN'])
    ngrok.forward(addr = '127.0.0.1:5000',
                proto = "http",
                domain = os.environ['DEPLOY_DOMAIN']
                )
    yield
    app.agent = None

app = FastAPI(lifespan = lifespan)

origins = [
    "http://localhost",
    "http://localhost:8080/",
    "http://localhost:62948/",
    "http://127.0.0.1:8000/",
    "http://127.0.0.1:8000",
    "https://mullet-immortal-labrador.ngrok-free.app"
]
app.add_middleware(CORSMiddleware, 
                   allow_origins=["*"], 
                   allow_credentials=True,
                   allow_methods=["*"],
                   allow_headers=["*"]
                   )

@app.post("/health_ask", response_class=JSONResponse)
async def main_router(request: Request):
    """
    - **Main router for answering question**
    - **Args:** 
        - query: string
    - **Returns:**
        - a string contains model answer
    - **Example of query:**
        - query = Dấu hiệu bệnh ung thư là gì? những bệnh ung thư phổ biến nào tại Việt Nam?
    """
    
    body_data = await request.json()
    print('body: ', body_data)

    query = body_data['query']
    try:
        agent_response = request.app.agent(query)
        return JSONResponse(status_code= 200, content= {'response': agent_response})
    except Exception as e:
        return JSONResponse(status_code= 500, content= 'server error')

async def main_run():
    config = uvicorn.Config("main:app", 
    	port=5000, 
    	log_level="info", 
    	reload=True
    	)
    server = uvicorn.Server(config)
    await server.serve()

if __name__ == "__main__":
    asyncio.run(main_run())