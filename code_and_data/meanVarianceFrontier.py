# The following code is used to determine 
# the minimum risk portfolio containing BTC and ETH
import quandl
import pandas as pd
import numpy as np
import matplotlib.pyplot as plt

# Import Data from Quandl
btc = quandl.get("BITFINEX/BTCUSD", authtoken="nyEaBHLDxQ7WB6GX5mbt")
eth = quandl.get("BITFINEX/ETHUSD", authtoken="nyEaBHLDxQ7WB6GX5mbt")
'''
writer = pd.ExcelWriter('BTC.xlsx')
btc.to_excel(writer,'Sheet1')
writer.save()
'''
# Extract Close Prices
btc = btc['Last']
btc = btc[-730::]
btcR = btc.copy()
eth = eth['Last']
eth = eth[-730::]
ethR = eth.copy()

# Specify Time Range
t = 7

# Iterate over days to achieve returns
for i in range(1,int(len(eth)/t)):
	btcR[i] = (btc[i*t] - btc[(i-1)*t])/btc[(i-1)*t]
	ethR[i] = (eth[i*t] - eth[(i-1)*t])/eth[(i-1)*t]

# Convert to array
btcR = np.array(btcR[1:int(len(eth)/t)])
ethR = np.array(ethR[1:int(len(eth)/t)])

# Aggregate Returns and create Covariance Matrix
X = np.matrix(np.vstack((btcR,ethR)).transpose())
Xhat = X - np.mean(X,0)
Cov = (1/(np.size(X,0)-1))*Xhat.transpose()*Xhat

# Calculate Minimal Risk Portfolio:
mu = np.mean(X,0).transpose()
CovInv = np.linalg.inv(Cov)
rho = Cov[0,1]/np.sqrt(Cov[0,0])*np.sqrt(Cov[1,1])
e = np.matrix([1,1]).transpose()
A = float(e.transpose()*CovInv*e)
B = float(mu.transpose()*CovInv*e)

sigmaG = 1/np.sqrt(A)
muG = B/A

wG = (CovInv*e)/(e.transpose()*CovInv*e)