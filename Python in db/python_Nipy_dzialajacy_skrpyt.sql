EXECUTE sp_execute_external_script
    @language = N'Python'
    , @script = N'
    , @input_data = N'SELECT DISTINCT SUBSTRING(BuyerIdentificationNumber,3,400) AS Nip FROM [dbo].[JPK_VatRegisters] WHERE BuyerIdentificationNumber LIKE 'PL%';'
    , @input_data_1_name  = N'NIPdf'
    , @output_data_1_name =  N'OutputDataSet'
import requests as r
import pandas as pd

#Get NIPs
#NIPdf = pd.DataFrame({"NIP":NipList})
NIPdf.insert(1,"GateResponse",None)
NIPdf.insert(2, "GateTextResponse",None)
NIPdf.insert(3,"MFResponse",None)
NIPdf.insert(4,"MFTextResponse",None)

#Send NIP and get response
url = "https://sprawdz-status-vat.mf.gov.pl"
proxies = { "https" : "http://10.106.4.80:3128", }
headers = {"content-type": "text/xml",
           "SOAPAction" : "http://www.mf.gov.pl/uslugiBiznesowe/uslugiDomenowe/AP/WeryfikacjaVAT/2018/03/01/WeryfikacjaVAT/SprawdzNIP"
           }
body = """ <soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/"
                xmlns:ns="http://www.mf.gov.pl/uslugiBiznesowe/uslugiDomenowe/AP/WeryfikacjaVAT/2018/03/01">
                 <soapenv:Header/>
                 <soapenv:Body>
                 <ns:NIP>%s</ns:NIP>
                 </soapenv:Body>
                </soapenv:Envelope>
"""

for n, NIP in enumerate(NIPdf["NIP"]):
    response = r.get(url
                      ,data=(body % (NIP,))
                      ,headers=headers
					  ,proxies = proxies
                      )
    NIPdf.at[n,"GateResponse"] = response.status_code #response http status code
    NIPdf.at[n,"GateTextResponse"] = r.status_codes._codes[response.status_code][0] #response http code description
    if response.status_code == 200:
        NIPdf.at[n, "MFResponse"] = response.text.split("<Kod>",1)[1].split("</Kod",1)[0] #response letter from mf gate
        #NIPdf.at[n, "MFTextResponse"] = response.text.split("<Komunikat>",1)[1].split("</Komunikat",1)[0] #response text from mf gate
        print( response.text.split("<Komunikat>",1)[1].split("</Komunikat",1)[0])
    if n == 2: break

pd.set_option("display.max_columns", 7)
print(NIPdf.head())
OutputDataSet = NIPdf
'
WITH RESULT SETS (( NIP nvarchar(256), ResponseStatusCode int, ResponseStatusText nvarchar(256), ResponseMFCode nvarchar(1), ResponseMFText nvarchar(256)))
