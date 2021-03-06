      SUBROUTINE FEER3
C                                                               T
C     FEER3 OBTAINS THE REDUCED TRIDIAGONAL MATRIX   (LI)*M*(LI)
C     WHERE M IS A SYMETRIC MATRIX AND L IS LOWER TRIANGULAR, AND (LI)
C     IS INVERSE OF L
C
C     THE TRANSFORMATION IS ALPHA = VT(L**(-1)M (L**-(1))TV
C     WHERE V IS A RECTANGULAR TRANSFORMATION.
C
C  Comments to follow refer to updates made 11/94.
C  This is a new version of FEER3.  The old version has been renamed FEER3X.
C  Diag 43 may be used to force the use of the old version.  The new version
C  uses all of available open core for storage of the orthogonal vectors,
C  the lower triangular matrix from SDCOMP, and the SMA matrix.  If 
C  insufficient memory is available, only part of the lower triangular 
C      
      INTEGER            SYSBUF    ,CNDFLG   ,MCBSCL(7),SR5FLE   ,
     1                   SR6FLE    ,SR7FLE   ,SR8FLE   ,
     2                   IZ(1)     ,NAME(2)  ,REW      ,WRTREW   ,
     3                   OPTN2    ,RDREW    ,SMAPOS
C     INTEGER            DASHQ
      DOUBLE PRECISION   LAMBDA    ,LMBDA    ,DZ(1)    ,DSQ
      COMMON   /FEERCX/  IFKAA(7)  ,IFMAA(7) ,IFLELM(7),IFLVEC(7),
     1                   SR1FLE    ,SR2FLE   ,SR3FLE   ,SR4FLE   ,
     2                   SR5FLE    ,SR6FLE   ,SR7FLE   ,SR8FLE   ,
     3                   DMPFLE    ,NORD     ,XLMBDA   ,NEIG     ,
     4                   MORD      ,IBK      ,CRITF    ,NORTHO   ,
     5                   IFLRVA    ,IFLRVC
      COMMON   /FEERXX/  LAMBDA    ,CNDFLG   ,ITER     ,TIMED    ,
     1                   L16       ,IOPTF    ,EPX      ,NOCHNG   ,
     2                   IND       ,LMBDA    ,IFSET    ,NZERO    ,
     3                   NONUL     ,IDIAG    ,MRANK    ,ISTART  
C
C  NIDSMA = IN-MEMORY INDEX FOR COLUMN DATA OF SMA MATRIX
C  NIDLT  = IN-MEMORY INDEX FOR LOWER TRIANGULAR MATRIX
C  NIDORV = IN-MEMORY INDEX FOR ORTHOGONAL VECTORS
C  NLTLI  = INDEX OF LAST STRING OF LOWER TRIANGULAR MATRIX HELD IN MEMORY
C  NSMALI = INDEX OF LAST STRING OF SMA MATRIX HELD IN MEMORY
C  IBFSMA = IN-MEMORY INDEX FOR BUFFER FOR OPENING SMA MATRIX
C  IBMLT  = IN-MEMORY INDEX FOR BUFFER FOR OPENING LOWER TRIANGULAR MATRIX
C  IBFORV = IN-MEMORY INDEX FOR BUFFER FOR ORTHOGONAL VECTORS
C  SMAPOS = POSITION OF RECORD FOLLOWING LAST RECORD READ INTO MEMORY
C           AND THE LAST RECORD OF MATRIX SMA (SEE SUBROUTINE DSCPOS)
C  LTPOS  = POSITION OF RECORD FOLLOWING LAST RECORD READ INTO MEMORY 
C           AND THE LAST RECORD OF THE LOWER TRIANGULAR MATRIX
C
      COMMON   /FEERIM/  NIDSMA    ,NIDLT    ,NIDORV   ,NLTLI    , 
     1                   NSMALI    ,IBFSMA   ,IBFLT    ,
     2                   IBFORV    ,SMAPOS(7),LTPOS(7)
      COMMON   /REIGKR/  OPTION    ,OPTN2
      COMMON   /TYPE  /  RC(2)     ,IWORDS(4)
      COMMON   /ZZZZZZ/  Z(1)
      COMMON   /SYSTEM/  SYSBUF    ,NOUT     ,SYSTM(52),IPREC    ,
     1                   SKIP36(38),KSYS94
      COMMON   /OPINV /  MCBLT(7)  ,MCBSMA(7),MCBVEC(7),MCBRM(7)
      COMMON   /UNPAKX/  IPRC      ,II       ,NN       ,INCR
      COMMON   /PACKX /  ITP1      ,ITP2     ,IIP      ,NNP      ,
     1                   INCRP
      COMMON   /NAMES /  RD        ,RDREW    ,WRT      ,WRTREW   ,
     1                   REW       ,NOREW    ,EOFNRW
      EQUIVALENCE        (IZ(1),Z(1),DZ(1))
      DATA      NAME  /  4HFEER,4H3   /      
C     DATA      DASHQ / 4H-Q    /
C
C     SR5FLE CONTAINS THE TRIDIAGONAL ELEMENTS
C     SR6FLE CONTAINS THE G VECTORS
C     SR7FLE CONTAINS THE ORTHOGONAL VECTORS
C     SR8FLE CONTAINS THE CONDITIONED MAA OR KAAD MATRIX
C     IFLVEC CONTAINS THE L OR C MATRIX FROM SDCOMP
C     IFLELM CONTAINS     KAA+ALPHA*MAA
C     IFLRVC CONTAINS THE RESTART AND/OR RIGID BODY VECTORS
C
      CALL SSWTCH ( 43, L43 )
      IF ( L43 .EQ. 0 ) GO TO 1
      CALL FEER3X
      GO TO 7777
1     CONTINUE
      IPRC      = MCBLT(5)
      NWDS      = IWORDS(IPRC)
      NZ        = KORSZ(Z)
      CALL MAKMCB (MCBVEC(1),SR7FLE,NORD,2,IPRC)
      MCBVEC(2) = 0
      MCBVEC(6) = 0
      CALL MAKMCB (MCBRM(1) ,SR6FLE,MORD,2,IPRC)
      MCBRM(2)  = 0
      MCBRM(6)  = 0
      MCBSCL(1) = IFLRVC
      CALL RDTRL (MCBSCL(1))
C
C     INITIALIZE ALLOCATIONS
C
      IBUF1  = NZ    - SYSBUF
      IBUF2  = IBUF1 - SYSBUF
      IBUF3  = IBUF2 - SYSBUF
      IBUF4  = IBUF3 - SYSBUF 
      IBFORV = IBUF1   
      IBFLT  = IBUF3
      IBFSMA = IBUF2
      IV1    = 1
      IV2    = IV1 + NORD
      IV2M1  = IV2 - 1    
      IV3    = IV2 + NORD
      IV4    = IV3 + NORD
      IV5    = IV4 + NORD
      IEND   = NWDS*(5*NORD + 1) + 2
      MAVAIL = IEND - IBUF4
      IF (MAVAIL .GT. 0) CALL MESAGE (-8,MAVAIL,NAME)
C
C COMPUTE THE MEMORY REQUIREMENT FOR ORTHOGONAL VECTORS
C
      MEMORT = NORD * ( MORD+NORTHO ) * IPRC
C
C COMPUTE THE MEMORY REQUIREMENT FOR THE LOWER TRIANGULAR MATRIX
C
      CALL DSSIZE ( MCBLT, NCOLS, NTERMS, NSTRGS, NWDTRM )
      MEMLT  = NTERMS*NWDTRM + NSTRGS*4
C
C COMPUTE THE MEMORY REQUIREMENT FOR THE SMA MATRIX
C
      CALL DSSIZE ( MCBSMA, NCOLS, NTERMS, NSTRGS, NWDTRM )
      MEMSMA = NTERMS*NWDTRM + NSTRGS*4
      IF ( L16 .EQ. 0 ) GO TO 2
      MINNEE = IEND + 4*SYSBUF
      MEMTOT = MEMORT + MEMLT + MEMSMA + MINNEE
      WRITE ( NOUT, 901 ) 
     &    MINNEE, MEMORT, MEMSMA, MEMLT, MEMTOT, NZ 
901   FORMAT(' FEER EIGENVALUE EXTRACTION NFORMATION'
     &,/, 5X,' THE FOLLOWING GIVES OPEN CORE REQUIREMENTS FOR KEEPING'
     &,/, 5X,' VARIOUS MATRICES AND VECTORS IN CORE FOR THE FEER'
     &,/, 5X,' EIGENVALUE EXTRACTION METHOD'
     &,/,10X,' MINIMUM NUMBER OF WORDS NEEDED IN OPEN CORE    =',I10   
     &,/,10X,' NUMBER OF WORDS FOR ORTHOGONAL VECTORS         =',I10
     &,/,10X,' NUMBER OF WORDS FOR SMA MATRIX                 =',I10
     &,/,10X,' NUMBER OF WORDS FOR LOWER TRIANGULAR MATRIX    =',I10 
     &,/,10X,' TOTAL NUMBER OF WORDS NEEDED TO ELIMINATE I/O  =',I10
     &,/,10X,' WORDS FOR OPEN CORE SPECIFIED IN THIS RUN      =',I10  
     & ) 
2     CONTINUE
C CHECK TO SEE IF MEMORY AVAILABLE FOR ORTHOGONAL VECTORS
      NIDORV = 0
      ITEST  = IEND + MEMORT
      IF ( ITEST .GT. IBUF4 ) GO TO 3
      NIDORV = IEND
      NIDORV = ( NIDORV/2 ) * 2 + 1
      IEND   = IEND + MEMORT
3     CONTINUE
C CHECK TO SEE IF MEMORY AVAILABLE FOR SMA MATRIX
      IRMEM  = IBUF4 - IEND
      IF ( IRMEM .LE. 10 ) GO TO 4
      NIDSMA = IEND
      NIDSMA = (NIDSMA/2) * 2  + 1
      MEMSMA = MEMSMA
      MEMSMA = MIN0 ( MEMSMA, IRMEM )
      IEND   = IEND + MEMSMA
      GO TO 5
4     CONTINUE
      NIDSMA = 0
      MEMSMA = 0
5     CONTINUE
C CHECK TO SEE IF MEMORY AVAILABLE FOR LOWER TRIANGULAR MATRIX
      IRMEM  = IBUF4 - IEND
      IF ( IRMEM .LE. 10 ) GO TO 6
      NIDLT  = IEND
      NIDLT  = (NIDLT/2) * 2 + 1
      MEMLT  = MEMLT
      MEMLT  = MIN0 ( MEMLT, IRMEM )
      IEND   = IEND + MEMLT
      GO TO 7
6     CONTINUE
      NIDLT  = 0
      MEMLT  = 0
7     CONTINUE
      LTPOS ( 4 ) = -1
      SMAPOS( 4 ) = -1
C      PRINT *,' FEER3, CALLING FERRDM,NIDSMA,NIDLT=',NIDSMA,NIDLT
      IF ( NIDSMA .EQ. 0 ) GO TO 11
      CALL FERRDM ( MCBSMA,NIDSMA,MEMSMA,IBFSMA,NSMALI,SMAPOS)
C      PRINT *,' RETURN FROM FERRDM,MEMSMA,NSMALI=',MEMSMA,NSMALI
C      PRINT *,' SMAPOS=',SMAPOS
11    IF ( NIDLT  .EQ. 0 ) GO TO 12
      CALL FERRDM ( MCBLT ,NIDLT ,MEMLT ,IBFLT ,NLTLI ,LTPOS )
C      PRINT *,' RETURN FROM FERRDM,MEMLT,NLTLI=',MEMLT,NLTLI
C      PRINT *,' LTPOS=',LTPOS
12    CONTINUE  
      IF ( L16 .EQ. 0 ) GO TO 8
      WRITE ( NOUT, 902 ) 'SMA',SMAPOS(1)
      WRITE ( NOUT, 902 ) 'LT ',LTPOS(1)
902   FORMAT(10X,' LAST COLUMN OF ',A3,' MATRIX IN MEMORY IS ',I4 )
C      PRINT *,' SMAPOS=',SMAPOS
C      PRINT *,' LTPOS =',LTPOS
8     CONTINUE
      CALL GOPEN (SR7FLE,Z(IBUF1),WRTREW)
      IF (NORTHO .EQ. 0) GO TO 130
C
C     LOAD RESTART AND/OR RIGID BODY VECTORS
C
      CALL GOPEN (IFLRVC,Z(IBUF2),RDREW)
      INCR  = 1
      INCRP = 1
      ITP1  = IPRC
      ITP2  = IPRC
      DO 110 J = 1,NORTHO
      II  = 1
      NN  = NORD
      CALL UNPACK (*110,IFLRVC,DZ(1))
      IIP = II
      NNP = NN
      IF (IPRC  .EQ. 1) GO TO 60
      IF (IOPTF .EQ. 0) GO TO 40
      DSQ = 0.D0
C      PRINT *,' FERR3 CALLING FRMLTX'
      CALL FRMLTX (MCBLT(1),DZ(IV1),DZ(IV2),DZ(IV3))
      DO 20 IJ = 1,NORD
   20 DSQ = DSQ + DZ(IV2M1+IJ)**2
      DSQ = 1.D0/DSQRT(DSQ)
      DO 30 IJ = 1,NORD
   30 DZ(IJ) = DSQ*DZ(IV2M1+IJ)
   40 CONTINUE
      GO TO 100
   60 IF (IOPTF .EQ. 0) GO TO 90
      SQ = 0.0
C      PRINT *,' FEER3 CALLING FRMLTA'
      CALL FRMLTA (MCBLT(1),Z(IV1),Z(IV2),Z(IV3))
      DO 70 IJ = 1,NORD
   70 SQ = SQ + Z(IV2M1+IJ)**2
      SQ = 1.0/SQRT(SQ)
      DO 80 IJ = 1,NORD
   80 Z(IJ) = SQ*Z(IV2M1+IJ)
   90 CONTINUE
  100 CALL PACK (DZ(1),SR7FLE,MCBVEC(1))
  110 CONTINUE
      CALL CLOSE (IFLRVC,NOREW)
  130 K = NORTHO
      CALL CLOSE (SR7FLE,NOREW)
      J = K
      NONUL = 0
      ITER  = 0
C      PRINT *,' FEER3,SR7FLE,IFLRVC,SR6FLE=',SR7FLE,IFLRVC,SR6FLE
C      PRINT *,' FEER3,SR6FLE,SR8FLE,SR5FLE=',SR6FLE,SR8FLE,SR5FLE
C      PRINT *,' FEER3,MCBSMA,MCBLT,MCBVEC=',MCBSMA(1),MCBLT(1),MCBSMA(1)
      CALL GOPEN (SR6FLE,Z(IBUF4) ,WRTREW)
      CALL CLOSE (SR6FLE,NOREW)
      IF ( SR8FLE .EQ. MCBSMA(1) ) GO TO 131
C      PRINT *,' PROBLEM IN FEER3, SR8FLE NE MCBSMA =',SR8FLE,MCBSMA(1)
      STOP
  131 CONTINUE
C      CALL GOPEN (SR8FLE,Z(IBUF2) ,RDREW )
      CALL GOPEN (SR5FLE,Z(IBUF4) ,WRTREW)
      CALL GOPEN (MCBSMA,Z(IBFSMA),RDREW )
      CALL GOPEN (MCBLT ,Z(IBFLT ),RDREW )
C
C     GENERATE SEED VECTOR
C
  140 K = K + 1
      J = K
      IFN = 0
C
C     GENERATE SEED VECTOR FOR LANCZOS
C
      SS = 1.0
      IF (IPRC .EQ. 1) GO TO 160
      DO 150 I = 1,NORD
      SS =-SS
      J  = J + 1
      DSQ = FLOAT(MOD(J,3)+1)/(3.0*FLOAT((MOD(J,13)+1)*(1+5*I/NORD)))
  150 DZ(IV2M1+I) = DSQ*SS
C      PRINT *,' FEER3 CALLING FERXTD'
      CALL FERXTD (DZ(IV1), DZ(IV2), DZ(IV3)
     1,            DZ(IV4), DZ(IV5), Z(IBUF1), IFN )
      GO TO 180
  160 DO 170 I = 1,NORD
      SS =-SS
      J  = J + 1
      SQ = FLOAT(MOD(J,3)+1)/(3.0*FLOAT((MOD(J,13)+1)*(1+5*I/NORD)))
  170 Z(IV2M1+I) = SQ*SS
C      IF (OPTN2 .EQ. DASHQ) GO TO 175 
      CALL FERXTS ( Z(IV1), Z(IV2)  , Z(IV3), Z(IV4 )
     1,             Z(IV5), Z(IBUF1), IFN)
      GO TO 180 
C  175 CALL FERXTQ ( Z(IV1), Z(IV2)  , Z(IV3), Z(IV4 )
C     1,              Z(IV5), Z(IBUF1), IFN)
  180 IF (ITER .LE. MORD) GO TO 190
      MORD = NORTHO - NZERO
      CNDFLG = 3
      GO TO 200
C
  190 IF (IFN .LT. MORD) GO TO 140
  200 CALL CLOSE (SR5FLE,NOREW)
      CALL CLOSE (SR8FLE,REW)
      CALL CLOSE (MCBLT ,REW)
 7777 CONTINUE
      RETURN
      END
