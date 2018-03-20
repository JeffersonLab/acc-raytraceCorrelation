import numpy as np, sys

#* Description:
#* Argument: $1 - 
#* Argument: $2 - 
#* Argument: $3+ - 
#* Example: 
#* Further Comments: 
#* Further Comments: 
#* Main Output:


# X = M * Q

# Where:

# X = Baseline chi2dof comparisons without any strength change
# M = Change vs Response matrix
# Q = Needed quadrupole strength changes

# Find Q

# Q = M^{-1} * X

# Store command line arguments as variables
xFile = sys.argv[1]
mFile = sys.argv[2]
qFile = sys.argv[3]
sFile = sys.argv[4]

# Load in comma separated text files A and B
X = np.loadtxt(xFile, delimiter=',')
M = np.loadtxt(mFile, delimiter=',')

# Use Singular Value Decomposition to calculate the U matrix, Eigenvalues, and Eigenvectors

# numpy svd factorization is U * np.diag(S) * V, so pseudoinverse is Vtranspose * Sinv * Utranspose
U, S, V = np.linalg.svd(M, full_matrices=False)

Sdiag = np.diag(S)
Sinverse = Sdiag

for n in range(0,Sdiag.shape[0]):
    if (abs(Sdiag[n,n])>1e-10):
        Sdiag[n,n]=1./Sdiag[n,n]

Utranspose = np.transpose(U)
Vtranspose = np.transpose(V)

# Re-construct the pseudo inverted C matrix and write to file
Q = Vtranspose.dot(Sinverse.dot(Utranspose.dot(X)))

outfile = open(sFile, "w")
for n in range(S.shape[0]):
	outfile.write(str(n+1)+" "+str(S[n])+"\n")

outfile = open(qFile,"w")
for n in range(Q.shape[0]):
    outfile.write(str(-Q[n])+"\n")

outfile.close()
