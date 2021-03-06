c
c
	subroutine Fsdiverg(zmid,ztop,zbot,ptop,pbot,mni,ni,nj,dx,dy,f,
     &                      Fsx,Fsy,w1,dtdx,dtdy,qx,qy,Fsdiv)
c
C###############################################################################
C Statement of purpose.
C ---------------------
C This routine computes the divergence of the along-isotherm component
C of the Q-vector for a specified layer in the atmosphere.
C
C History.
C --------                    
C E. Thaler                original version 3 Sep 91
C
C Description of input and output.
C --------------------------------
C On input:
C ---------                
c mni         Integer       First dimension of input array.
C ni, nj      Integer       Number of points in the x- and y-directions.
C dx, dy      Real Array    Grid spacing in the x- and y-directions (m).
C f           Real Array    Coriolis parameter at each grid point (/s).
C ztop        Real Array    Heights at each grid point for the top of the
C                           layer (m asl)
C zbot        Real Array    Same as ztop except for the bottom of the layer
C                           (m asl).
C ptop        Real          Pressure level corresponding to ztop (mb).
C pbot        Real          Pressure level corresponding to zbot (mb).
C zmid        Real Array    work array for Q-vector calculations
C Fsx-dtdy    Real Array    Work arrays.
C qx, qy      Real Array    Work arrays holding the Q-vector components.
C
C On output:
C ----------               
C Fsdiv        Real Array    Fs vector divergence at the grid points
C                            (K/m^2/sec)
C
C User notes:
C -----------
C 1. No scaling of the output is done in this routine.
C
C###############################################################################
c
	implicit none
c
	integer mni, ni, nj, i, j
	real flag, bad, ptop, pbot, tempgrad, piover2
c
c---- Declare input arguments.
c
	real dx(mni,nj), dy(mni,nj)
	real f(mni,nj), ztop(mni,nj), zbot(mni,nj), zmid(mni,nj)
c
c---- Declare output arguments.
c
	real Fsdiv(mni,nj)
c
c---- Declare other parameters and work arrays.
c
	parameter(flag = 1.e37)
	real w1(mni,nj), dtdx(mni,nj), dtdy(mni,nj)
	real Fsx(mni,nj), Fsy(mni,nj)
	real qx(mni,nj), qy(mni,nj)
c
	bad = 1.e6 - 2.
        piover2 = acos(-1.)/2
c
c---- Compute the Q-vector components.
c
	call qvector(zmid,ztop,zbot,ptop,pbot,mni,ni,nj,dx,dy,f,
     &               Fsx,Fsy,w1,Fsdiv,dtdx,dtdy,qx,qy)
c
c---- Compute Fs-vectors (component of Q parallel to the temperature
c---- gradient vector) then compute x- and y-components of Fs vectors.
c
	do 200 j = 1,nj
	   do 100 i = 1,ni
	       If ( (qx(i,j).gt.bad) .or. (qy(i,j).gt.bad) .or. 
     & 		    (dtdx(i,j).gt.bad) .or. (dtdy(i,j).gt.bad) ) Then
			Fsx(i,j) = flag
			Fsy(i,j) = flag
	       Else
                  tempgrad = dtdx(i,j)**2+dtdy(i,j)**2
		  If (tempgrad .lt. 1.e-15) Then
			Fsx(i,j) = qx(i,j)
			Fsy(i,j) = qy(i,j)
		  Else
                     tempgrad = (qx(i,j)*dtdy(i,j) - qy(i,j)*dtdx(i,j))/
     &                           tempgrad
		     Fsx(i,j) =   dtdy(i,j) *tempgrad
	             Fsy(i,j) = (-dtdx(i,j))*tempgrad
		  Endif
               Endif
  100	   continue
  200	continue
c
c---- Compute the divergence.
c
        call G2Gkinematics(Fsx,Fsy,f,dx,dy,mni,nj,ni,nj,2,Fsdiv)
c
	return
	end
