ALTER PROC checkVIES AS
EXECUTE sp_execute_external_script
    @language = N'Python'
    , @script = N'import requests as r
import pandas as pd

NipList = ["PL7630003498","PL8730006829","PT504220560","DE111628131","GB195929307"]
NIPdf = pd.DataFrame({"VATUE":NipList})
NIPdf.insert(1,"GateResponse",None)
NIPdf.insert(2, "GateTextResponse",None)
NIPdf.insert(3,"MFResponse",None)
NIPdf.insert(4,"MFTextResponse",None)

#Send NIP and get response
url = "http://ec.europa.eu/taxation_customs/vies/services/checkVatService"
proxies = { "http" : "http://10.106.4.80:3128", }
headers = {"content-type": "text/xml",
           "SOAPAction" : ""
           }
body = """ <s:Envelope xmlns:s="http://schemas.xmlsoap.org/soap/envelope/">
            <s:Body>
                <checkVatApprox xmlns="urn:ec.europa.eu:taxud:vies:services:checkVat:types">
                <countryCode>%s</countryCode>
                <vatNumber>%s</vatNumber>
                </checkVatApprox>
             </s:Body>
            </s:Envelope>";

"""

for n, vatUe in enumerate(NIPdf["VATUE"]):
    prefix = vatUe[0:2]
    NIP = vatUe[2:]
    response = r.post(url
                      ,data=(body % (prefix, NIP,))
                      ,headers=headers
					  ,proxies=proxies
                      )
    NIPdf.at[n,"GateResponse"] = response.status_code #response http status code
    NIPdf.at[n,"GateTextResponse"] = r.status_codes._codes[response.status_code][0] #response http code description
    if response.status_code == 200:
        print(response.text)
       # NIPdf.at[n, "MFResponse"] = response.text.split("<Kod>",1)[1].split("</Kod",1)[0] #response letter from mf gate
       # NIPdf.at[n, "MFTextResponse"] = response.text.split("<Komunikat>",1)[1].split("</Komunikat",1)[0] #response text from mf gate
       # print( response.text.split("<Komunikat>",1)[1].split("</Komunikat",1)[0])
    # if n == 1: break

pd.set_option("display.max_columns", 7)
print(NIPdf.head())
'

