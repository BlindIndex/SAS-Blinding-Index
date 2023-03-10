*Blinding Indexes - Generalized and Unified Framework

James' and Bang's BIs are to access effectiveness of blinding in clinical trials.

Sourse: https://pubmed.ncbi.nlm.nih.gov/8841652/
		https://pubmed.ncbi.nlm.nih.gov/15020033/

X is a 3x2 matrix of cross counts and has the following table general structure:
          |     Assignment      |
          |---------------------|
  Guess	  | Treatment | Placebo |			
----------|---------------------|
Treatment |    n11    |   n12   |          |n11 n12|
Placebo   |    n21    |   n22   |  --> X = |n21 n22|
Don't Know|    n31    |   n33   |          |n31 n32|

JAMES_WEIGHTS is 3x2 matrix of the weights assigned and has the following structure and default values:
          |     Assignment      |
          |---------------------|
  Guess	  | Treatment | Placebo |			
----------|---------------------|
Treatment |    w11    |   w12   |                      |w11 w12|   |0    0.75|
Placebo   |    w21    |   w22   |  --> JAMES_WEIGHTS = |w21 w22| = |0.75    1|
Don't Know|    w31    |   w33   |                      |w31 w32|   |1       1|

Note: user-defined JAMES_WEIGHTS must be in [0, 1].

Note: for James' BI, X may have two treatment arms:
                 |                Assignment                  |
                 |--------------------------------------------|
     Guess       |Treatment, dose1| Treatment, dose2| Placebo |
-----------------|----------------------------------|---------|
Treatment, dose1 |       n11   	  |       n12       |	n13   |         |n11 n12 n13|
Treatment, dose2 |       n21   	  |       n22       |	n23   | --> X = |n21 n22 n23|
Placebo          |       n31   	  |       n32       |	n33   |         |n31 n32 n33|
Don't Know       |       n41   	  |       n42       |	n43   |         |n41 n42 n43|

and the accompanying weights as the following:
                 |                Assignment                  |
                 |--------------------------------------------|
     Guess       |Treatment, dose1| Treatment, dose2| Placebo |
-----------------|----------------------------------|---------|
Treatment, dose1 |       w11   	  |       w12       |	w13   |                     |w11 w12 w13|   |0     0.5  0.75|
Treatment, dose2 |       w21   	  |       w22       |	w23   | --> JAMES_WEIGHTS = |w21 w22 w23| = |0.5     0  0.75|
Placebo          |       w31   	  |       w32       |	w33   |                     |w31 w32 w33|   |0.75 0.75     0|
Don't Know       |       w41   	  |       w42       |	w43   |                     |w41 w42 w43|   |1       1     1|


NOTE: for Bang's BI, X may have five levels of guessing.
	  In this case an ancillary table for the subjects who answered Don't Know should be provided.
	  To estimate James BI, Strongly Believe Treatment & Somewhat Believe Treatment aggregated as Treatment,
	  Somewhat Believe Treatment & Strongly Believe Placebo aggregated as Placebo: 5x2 matrix will be transformed into 3x2 matrix.

5x2 input matrix structure:
         Guess            | Treatment | Placebo |
--------------------------|---------------------|
Strongly Believe Treatment|    n11    |   n12   |         |n11 n12|
Somewhat Believe Treatment|    n21    |   n22   |         |n21 n22|
Somewhat Believe Placebo  |    n31    |   n32   | --> X = |n31 n32|
Strongly Believe Plecebo  |    n41    |   n42   |         |n41 n42|
Don't know                |    n51    |   n52   |         |n51 n52|


2x2 ancillary matrix structure:

  Guess   | Treatment | Placebo |
----------|---------------------|
Treatment |     n11   |	  n12   | --> ANCILLARY = |n11 n12|
Placebo   |     n21   |	  n22   |                 |n21 n22|


For Bang's BI, each arm (Treatment and Placebo) assesed separately,
the weight matrix for a 5x2 input matrix without an ancillary table has the following structure and default values:
                |w11|   |1   |
                |w21|   |0.5 |
BANG_WEIGHTS =  |w31| = |-0.5|
                |w41|   |-1  |
                |w51|   |0   |

the weight matrix for a 5x2 input matrix with an ancillary table has the following structure and default values:
                |w11|   |1    |
                |w21|   |0.5  |
                |w31|   |-0.5 |
BANG_WEIGHTS = 	|w41| = |-1   |
                |w51|   |0.25 |
                |w61|   |-0.25|

Note: absolute value of user-defined BANG_WEIGHTS must be in [0, 1].
Note: the sum of Bang's weigths must be zero and weights should be symmetric as described in
Bang, H., Flaherty, S. P., Kolahi, J., & Park, J. (2010). Blinding assessment in clinical trials: 
A review of statistical methods and a proposal of blinding assessment protocol. Clinical Research and Regulatory Affairs, 27(2), 42-51.

DIRECTION is an option to specify a type of the confidence limits:

DIRECTION = 'twosided' - to speicy two-sided 95% confidence limits -- DEFAULT
DIRECTION = 'lower'	   - to specify lef-sided 95% confidence limits
DIRECTION = 'upper'  - to specify right-sided 95% confidence limits
;

%macro BI(X, ANCILLARY=%str({}), JAMES_WEIGHTS=%str({}), BANG_WEIGHTS=%str({}), DIRECTION='TWOSIDED');
	title;
	footnote;
	dm 'odsresults; clear; output; clear log; clear;';

	*custom templates;
	proc template;
		define table Custom1;
			column Guess Treatment Placebo;
			define column Guess;
				define header Guessh;
					just = c;
					vjust = c;
				end;

				header = Guessh;
			end;

			define column Treatment;
				justify = on;
				just = c;
			end;

			define column Placebo;
				justify = on;
				just = c;
			end;

			define header SpanHeader;
				text "Treatment Assignment";
				start = Treatment;
				end   = Placebo;
			end;
		end;
	run;

	proc template;
		define table Custom2;
			column Guess Treatment1 Treatment2 Placebo;
			define column Guess;
				define header Guessh;
					just = c;
					vjust = c;
				end;

				header = Guessh;
			end;

			define column Treatment1;
				define header Treatment1h;
					text 'Treatment, Dose 1';
				end;

				header = Treatment1h;
				justify = on;
				just = c;
			end;

			define column Treatment2;
				define header Treatment2h;
					text 'Treatment, Dose 2';
				end;

				header = Treatment2h;
				justify = on;
				just = c;
			end;

			define column Placebo;
				justify = on;
				just = c;
			end;

			define header SpanHeader;
				text "Treatment Assignment";
				start = Treatment1;
				end   = Placebo;
			end;
		end;
	run;

	proc template;
		define table Custom3;
			column Guess Treatment Placebo Weights;
			define column Guess;
				define header Guessh;
					just = c;
					vjust = c;
				end;

				header = Guessh;
			end;

			define column Treatment;
				justify = on;
				just = c;
			end;

			define column Placebo;
				justify = on;
				just = c;
			end;

			define header SpanHeader;
				text "Treatment Assignment, 3x2";
				start = Treatment;
				end   = Placebo;
			end;

			define column Weights;
				define header Weightsh;
					text 'Weights';
					just = c;
					vjust = c;
				end;

				header = Weightsh;
				justify = on;
				just = c;
			end;
		end;
	run;

	proc template;
		define table Custom4;
			column Guess Treatment Placebo Weights;
			define column Guess;
				define header Guessh;
					just = c;
					vjust = c;
				end;

				header = Guessh;
			end;

			define column Treatment;
				justify = on;
				just = c;
			end;

			define column Placebo;
				justify = on;
				just = c;
			end;

			define header SpanHeader;
				text "Treatment Assignment, 5x2";
				start = Treatment;
				end   = Placebo;
			end;

			define column Weights;
				define header Weightsh;
					text 'Weights';
					just = c;
					vjust = c;
				end;

				header = Weightsh;
				justify = on;
				just = c;
			end;
		end;
	run;
	*end of custom templates;

	*James BI;
	proc iml;
		x = &X;
		a = &ANCILLARY;
		nrowX = nrow(x);
		ncolX = ncol(x);
		JAMES_WEIGHTS = &JAMES_WEIGHTS;
		
		*synmmetry function;
		start TestSym(A);
		   if nrow(A) ^= ncol(A) then return(0);
		   c = max(abs(A));
		   sqrteps = constant('SqrtMacEps');
		   return( all( abs(A-A`) < c*sqrteps ) );
		finish;

		*check for any missing value in X;
		m = missing(x);
		RowMissing = m[,+];
		maxC = RowMissing[<>,];

		*check for any negative value in X;
		minX = x[><];

		*check for any missing or negative value in ANCILLARY;
		maxCa = 0;
		minA = 0;
		if IsEmpty(a) = 0 then
			do;
				ma = missing(a);
				RowMissing = ma[,+];
				maxCa = RowMissing[<>,];
				minA = a[><];
			end;

		if length(&direction) > 0 & upcase(&direction) ^= 'TWOSIDED' & upcase(&direction) ^= 'LOWER' & upcase(&direction) ^= 'UPPER' then do;
			print 'ERROR: DIRECTION is misspelled.';
			abort 'ERROR: DIRECTION is misspelled.';
		end;

		if maxC > 0 | minX < 0 | maxCa > 0 | minA < 0 then do;
			print 'ERROR: X and ANCILLARY cannot have any missing or negative value.';
			abort 'ERROR: X and ANCILLARY cannot have any missing or negative value.';
		end;
		else
			do;
				*aggregate responses if x is a 5x2 matrix;
				if nrowX = 5 then
					do;
						row1 = x[1,] + x[2,];
						row2 = x[3,] + x[4,];
						x = x[5,];
						x = insert(x, row2, 1, 0);
						x = insert(x, row1, 1, 0);
						nrowX = nrow(x);
						ncolX = ncol(x);
					end;

				N = x[+];
				rowTot = x[,+];
				x = insert(x, rowTot, 0, ncolX + 1);
				colTot = x[+,];
				x = insert(x, colTot, nrowX + 1);

				if nrowX = 3 then
					do;
						Weights={0 0.75, 0.75 0, 1 1};

						if IsEmpty(JAMES_WEIGHTS) = 0 then
							do;
								nrowJAMES_WEIGHTS = nrow(JAMES_WEIGHTS);
								ncolJAMES_WEIGHTS = ncol(JAMES_WEIGHTS);

								if nrowJAMES_WEIGHTS = 3 & ncolJAMES_WEIGHTS = 2 & 
									0 <= JAMES_WEIGHTS[<>] & JAMES_WEIGHTS[<>] <= 1 & 0 <= JAMES_WEIGHTS[><] & JAMES_WEIGHTS[><] <= 1 &
									testsym(JAMES_WEIGHTS[1:2, 1:2]) = 1 & JAMES_WEIGHTS[3, 1] = JAMES_WEIGHTS[3, 2] &
									JAMES_WEIGHTS[1, 1] < JAMES_WEIGHTS[2, 1] & JAMES_WEIGHTS[2, 1] < JAMES_WEIGHTS[3, 1] then
									Weights = JAMES_WEIGHTS;
								else
									do;
										print "ERROR: James' weights have wrong structure or values.";
										call execute('%put ' + "ERROR: " +  "James weights have wrong structure or values." + ';');
										goto Bang;
									end;
							end;

						print "James' Blinding Index (BI): ranges from 0 to 1";
						assignment = x[1:3, 1:2];
						vars = {'Treatment', 'Placebo', "Don't know"};
						tbl = TableCreate("Guess", vars);
						call TableAddVar(tbl, {'Treatment' 'Placebo'}, assignment);
						call TablePrint(tbl) template="Custom1";
						x22 = x[1:2, 1:2];
						Tot22 = x22[+];
						WeightsDef=Weights[,1]`;
						vars = {'Weight'};
						tbl = TableCreate(' ', vars);
						call TableAddVar(tbl, {'Correct Guess' 'Wrong Guess' "Don't know"}, WeightsDef);
						call TablePrint(tbl) ID = ' ' justify = {c c c c} label = "James' BI: Weights and Definitions";
					end;
				else if nrowX = 4 then
					do;
						Weights={ 0 0.5 0.75, 0.5 0 0.75, 0.75 0.75 0, 1 1 1 };

						if IsEmpty(JAMES_WEIGHTS) = 0 then
							do;
								nrowJAMES_WEIGHTS = nrow(JAMES_WEIGHTS);
								ncolJAMES_WEIGHTS = ncol(JAMES_WEIGHTS);

								if nrowJAMES_WEIGHTS = 4 & ncolJAMES_WEIGHTS = 3 & 
									0 <= JAMES_WEIGHTS[<>] & JAMES_WEIGHTS[<>] <= 1 & 0 <= JAMES_WEIGHTS[><] & JAMES_WEIGHTS[><] <= 1 &
									testSym(JAMES_WEIGHTS[1:3, 1:3]) = 1 & JAMES_WEIGHTS[4, 1] = JAMES_WEIGHTS[4, 2] & JAMES_WEIGHTS[4, 2] = JAMES_WEIGHTS[4, 3] &
									JAMES_WEIGHTS[1, 1] < JAMES_WEIGHTS[2, 1] & JAMES_WEIGHTS[2, 1] < JAMES_WEIGHTS[3, 1] & JAMES_WEIGHTS[3, 1] < JAMES_WEIGHTS[4, 1]
									then
									Weights = JAMES_WEIGHTS;
								else
									do;
										print "ERROR: James' weights have wrong structure or values.";
										call execute('%put ' + "ERROR: " +  "James weights have wrong structure or values." + ';');
										goto Bang;
									end;
							end;

						print "James' Blinding Index (BI): ranges from 0 to 1";
						assignment = x[1:4, 1:3];
						vars = {'Treatment, Dose 1', 'Treatment, Dose 2', 'Placebo', "Don't know"};
						tbl = TableCreate("Guess", vars);
						call TableAddVar(tbl, {'Treatment1' 'Treatment2' 'Placebo'}, assignment);
						call TablePrint(tbl) template="Custom2";
						x32 = x[1:3, 1:2];
						Tot22=x32[+];
						WeightsDef=Weights[,1]`;
						vars = {'Weight'};
						tbl = TableCreate(' ', vars);
						call TableAddVar(tbl, {'Correct Guess' 'Correct Treatment, Wrong Dose'  'Wrong Treatment' "Don't know"}, WeightsDef);
						call TablePrint(tbl) ID = ' ' justify = {c c c c c} label = "James' BI: Weights and Definitions";
					end;
				else if nrowX >< 5 then
					do;
						print "ERROR: X has wrong structure to estimate James' BI";
						call execute('%put ' + "ERROR: " +  "X has wrong structure to estimate James BI." + ';');
						stop;
					end;

				P = x / max(x);
				Pdk = P[nrow(P) - 1, ncol(P)];
				Pdo = 0;
				Pde = 0;
				denom = 0;
				JamesBI = j(1, 4, .);

				if Tot22 > 0 then
					do;
						do i=1 to (nrow(P) - 2);
							do j=1 to (ncol(P) - 1);
								Pdo = Pdo + ((Weights[i, j] * P[i, j]) / (1 - Pdk));
								Pde = Pde + ((Weights[i, j] * P[i, ncol(P)] * (P[nrow(P), j] - P[nrow(P) - 1, j])) / (1 - Pdk) ** 2);
								denom = denom + Weights[i, j] * P[i, ncol(P)] * (P[nrow(P), j] - P[nrow(P) - 1, j]);
							end;
						end;

						denom = 4 * denom ** 2;
						Kd = (Pdo - Pde) / Pde;
						JamesBI[1,1] = round((1 + Pdk + (1 - Pdk) * Kd) / 2, .001);
						num = 0;

						do i=1 to nrow(P) - 2;
							do j=1 to ncol(P) - 1;
								part2 = 0;

								do r=1 to ncol(P) - 1;
									part2 = part2 + (weights[r, j] * P[r, ncol(P)] + Weights[i, r] * (P[nrow(P), r] - P[nrow(P) - 1, r]));
								end;

								num = num + ((P[i, j] * (1 - Pdk) ** 2 * ((1 - Pdk) * Weights[i, j] - (1 + Kd) * part2) ** 2));
							end;
						end;

						v = (num / denom + Pdk * (1 - Pdk) - (1 - Pdk) * (1 + Kd) * (Pdk + ((1 - Pdk) * (1 + Kd)) / 4));
						JamesBI[,2] = (v / x[nrow(x), ncol(x)]) ** 0.5;
					end;
				else if Tot22 = 0 then
					do;
						JamesBI[1, 1] = 1;
						JamesBI[1, 2] = 0;
					end;

				if length(&direction)= 0 | upcase(&direction)= ("TWOSIDED") then
					do;
						JamesBI[1, 3] = JamesBI[1, 1] - quantile('normal', 0.975) * JamesBI[1, 2];
						JamesBI[1, 4] = JamesBI[1, 1] + quantile('normal', 0.975) * JamesBI[1, 2];
						l = "James' BI, two-sided Confidence Interval (CI)";
					end;

				if upcase(&direction)= "LOWER" then
					do;
						JamesBI[1, 3] = 0;
						JamesBI[1, 4] = JamesBI[1, 1] + quantile('normal', 0.95) * JamesBI[1, 2];
						l = "James' BI, one-sided Confidence Interval (CI)";
					end;
				else if upcase(&direction) = "UPPER" then
					do;
						JamesBI[1, 3] = JamesBI[1, 1] - quantile('normal', 0.95) * JamesBI[1, 2];
						JamesBI[1, 4] = 1;
						l = "James' BI, one-sided Confidence Interval (CI)";
					end;

				vars = {'Overall'};
				tbl = TableCreate("Type", vars);
				call TableAddVar(tbl, {'BI Estimate' 'Std Err' 'Lower 95% CL' 'Upper 95% CL'}, JamesBI);
				call TableSetVarFormat(tbl, {'BI Estimate' 'Std Err' 'Lower 95% CL' 'Upper 95% CL'}, {'7.3' '7.3' '7.3' '7.3'});
				call TablePrint(tbl) ID = 'Type' justify = {c c c c c} label = l;
				*End of James BI;

				print '------------------------------------------------------------------------------------------';

				*Bang BI;
				Bang:;
				x = &X;
				a = &ANCILLARY;
				nrowX = nrow(x);
				BANG_WEIGHTS = &BANG_WEIGHTS;

				if IsEmpty(BANG_WEIGHTS) = 0 then
					BANG_WEIGHTScolTot = round(sum(BANG_WEIGHTS), 0.00000001);

				if nrowX = 3 | nrowX = 5 then
					do;
						print "Bang's Blinding Index (BI): ranges from -1 to 1 - each treatment arm assessed separately";
						BangBI = j(2, 4, .);
						nrowX32 = 0;

						*aggregate responses if x is a 5x2 matrix;
						if nrowX = 5 then
							do;
								BangBI = j(4, 4, .);
								x32 = x;
								row1 = x[1,] + x[2,];
								row2 = x[3,] + x[4,];
								x32 = x[5,];
								x32 = row1 // row2 // x32;
								nrowX32 = nrow(x32);
							end;

						arms = {'Treatment, 3x2', 'Placebo, 3x2'};

						*3x2;
						if nrowX = 3 | nrowX32 = 3 then
							do;
								if nrowX32 = 0 then
									x32 = x;
								assignment = x32[1:3, 1:2];
								x22 = x32[1:2, 1:2];
								colTot22=x22[+,];
								N = x32[+];
								nrowX32 = nrow(x32);
								ncolX32 = ncol(x32);
								rowTot32 = x32[,+];
								x32 = insert(x32, rowTot32, 0, ncolX32 + 1);
								colTot32 = x32[+,];
								x32 = insert(x32, colTot32, nrowX32 + 1);
								x32 = x32`;

								do i=1 to 2;
									if colTot22[1,i] > 0 then
										BangBI[i,1] = (2 * (x32[i, i] / (x32[i, 1] + x32[i, 2])) - 1) * ((x32[i, 1] + x32[i, 2]) / 
										(x32[i, 1] + x32[i, 2] + x32[i, 3])); *BI est;
									BangBI[i,2] = sqrt(((x32[i, 1] / x32[i, ncol(x32)]) * (1 - (x32[i, 1] / x32[i, ncol(x32)])) +
										(x32[i, 2] / x32[i, ncol(x32)]) * (1 - (x32[i, 2] / x32[i, ncol(x32)])) +
										2 * (x32[i, 1] / x32[i, ncol(x32)]) * (x32[i, 2] / x32[i, ncol(x32)])) / x32[i, ncol(x32)]); *BI SE;
								end;

								WeightsDef = {1 -1 0};
								assignment = assignment || WeightsDef`;
								vars = {'Treatment', 'Placebo', "Don't know"};
								tbl = TableCreate("Guess", vars);
								call TableAddVar(tbl, {'Treatment' 'Placebo' 'Weights'}, assignment);
								call TablePrint(tbl) template="Custom3";
							end;

						*5x2 with a 2x2 ancillary;
						if nrowX = 5 & IsEmpty(a) = 0 then
							do;
								Weights = {1, 0.5, -0.5, -1, 0.25, -0.25};

								if IsEmpty(BANG_WEIGHTS) = 0 then
									do;
										nrowBANG_WEIGHTS = nrow(BANG_WEIGHTS);
										ncolBANG_WEIGHTS = ncol(BANG_WEIGHTS);

										if nrowBANG_WEIGHTS = 6 & ncolBANG_WEIGHTS = 1 & BANG_WEIGHTScolTot = 0  & 
											0 <= abs(BANG_WEIGHTS[<>]) & abs(BANG_WEIGHTS[<>]) <= 1 & 0 <= abs(BANG_WEIGHTS[><]) & abs(BANG_WEIGHTS[><]) <= 1 &
											abs(BANG_WEIGHTS[1, 1])  = abs(BANG_WEIGHTS[4, 1]) & abs(BANG_WEIGHTS[2, 1])  = abs(BANG_WEIGHTS[3, 1]) & abs(BANG_WEIGHTS[5, 1]) = abs(BANG_WEIGHTS[6, 1]) &
											abs(BANG_WEIGHTS[1, 1]) >= abs(BANG_WEIGHTS[2, 1]) & abs(BANG_WEIGHTS[2, 1]) >= abs(BANG_WEIGHTS[5, 1])
										then Weights = BANG_WEIGHTS;
										else do;
											print "Bang's weights have wrong structure or their sum is not zero.";
											call execute('%put ' + "ERROR: " +  "Bangs weights have wrong structure or their sum is not zero." + ';');
											stop;
										end;
									end;

								colTot = x[+,];

								*remove Dont Know row;
								x = x[1:4,];
								assignment = x // a || Weights;

								*modify the second column in x and a matrices;
								x1 = x[, 1];
								x2 = x[4:1, 2];
								x = x1||x2;
								a1 = a[, 1];
								a2 = a[2:1, 2];
								a = a1||a2;

								*combine  matrices x and a;
								x = x // a;
								vars = {'Strongly Believe Treatment', 'Somewhat Believe Treatment', 'Somewhat Believe Placebo', 'Strongly Believe Placebo', 
									'Second Guess: Treatment', 'Second Guess: Placebo'};
								tbl = TableCreate("Guess", vars);
								call TableAddVar(tbl, {'Treatment' 'Placebo' 'Weights'}, assignment);
								call TablePrint(tbl) template = "Custom4";

								*create empty matrices;
								P   = j(6, 2, .);
								Q   = j(6, 2, 1);
								WP  = j(5, 2, .);
								W2P = j(6, 2, .);

								do i=1 to ncol(x);
									P[, i] = x[, i] / colTot[1, i];
									Q[, i] = Q[, i] - P[, i];
								end;

								do i = 1 to ncol(x);
									do j = 1 to nrow(x)-1;
										WP[j, i] = 2 * (Weights[j, 1] * Weights[(j + 1) : nrow(x), 1])` * P[j, i] * P[(j + 1) : nrow(x), i];
									end;
								end;

								colTotWP = WP[+,];

								do i=1 to 2;
									BangBI[i + 2, 1] = x[, i]` * Weights / colTot[1, i];

									*BI est;
									do j = 1 to nrow(x);
										W2P[j, i] = Weights[j, 1] ## 2 * P[j, i] * Q[j, i];
										coltotW2P = W2P[+,];
										BangBI[i + 2, 2] = (coltotW2P[1, i] + colTotWP[1, i]) / colTot[1, i]; *BI SE;
										BangBI[i + 2, 2] = (choose(BangBI[i + 2, 2] >= 0, BangBI[i + 2, 2], .)) ** 0.5; *BI SE;
									end;
								end;

								arms = {'Treatment, 3x2', 'Placebo, 3x2', 'Treatment, 5x2', 'Placebo, 5x2'};
							end;

						*5x2 without a 2x2 ancillary;
						if nrowX = 5 & IsEmpty(a) = 1 then
							do;
								Weights = {1, 0.5, -0.5, -1, 0};

								if IsEmpty(BANG_WEIGHTS) = 0 then
									do;
										nrowBANG_WEIGHTS = nrow(BANG_WEIGHTS);
										ncolBANG_WEIGHTS = ncol(BANG_WEIGHTS);

										if nrowBANG_WEIGHTS = 5 & ncolBANG_WEIGHTS = 1 & BANG_WEIGHTScolTot = 0  & 
											0 <= abs(BANG_WEIGHTS[<>]) & abs(BANG_WEIGHTS[<>]) <= 1 & 0 <= abs(BANG_WEIGHTS[><]) & abs(BANG_WEIGHTS[><]) <= 1 &
											abs(BANG_WEIGHTS[1, 1])  = abs(BANG_WEIGHTS[4, 1]) & abs(BANG_WEIGHTS[2, 1]) =  abs(BANG_WEIGHTS[3, 1]) &
											abs(BANG_WEIGHTS[1, 1]) >= abs(BANG_WEIGHTS[2, 1]) & abs(BANG_WEIGHTS[2, 1]) >= abs(BANG_WEIGHTS[5, 1])
										then Weights = BANG_WEIGHTS;
										else do;
											print "Bang's weights have wrong structure or their sum is not zero.";
											call execute('%put ' + "ERROR: " +  "Bangs weights have wrong structure or their sum is not zero." + ';');
											stop;
										end;
									end;

								print 'No ancillary table';
								assignment = x || Weights;
								vars = {'Strongly Believe Treatment', 'Somewhat Believe Treatment', 'Somewhat Believe Placebo', 'Strongly Believe Placebo', "Don't know"};
								tbl = TableCreate("Guess", vars);
								call TableAddVar(tbl, {'Treatment' 'Placebo' 'Weights'}, assignment);
								call TablePrint(tbl) template = "Custom4";
								colTot = x[+,];

								*create empty matrices;
								P   = j(5, 2, .);
								Q   = j(5, 2, 1);
								WP  = j(5, 2, .);
								W2P = j(5, 2, .);

								do i=1 to ncol(x);
									P[, i]  = x[, i] / colTot[1, i];
									Q[, i] = Q[, i] - P[, i];
								end;

								do i = 1 to ncol(x);
									if i = ncol(x) then
										Weights = -1 * Weights;

									do j = 1 to nrow(x)-1;
										WP[j, i] = 2 * (Weights[j, 1] * Weights[(j + 1) : nrow(x), 1])` * P[j, i] * P[(j + 1) : nrow(x), i];
									end;
								end;

								colTotWP = WP[+,];
								Weights = -1 * Weights;

								do i=1 to 2;
									if i = ncol(x) then
										Weights = -1 * Weights;
									BangBI[i + 2, 1] = x[, i]` * Weights / colTot[1, i];

									*BI est;
									do j = 1 to nrow(x);
										W2P[j, i] = Weights[j, 1] ## 2 * P[j, i] * Q[j, i];
										coltotW2P = W2P[+,];
										BangBI[i + 2, 2] = (coltotW2P[1, i] + colTotWP[1, i]) / colTot[1, i]; *BI SE;
										BangBI[i + 2, 2] = (choose(BangBI[i + 2, 2] >= 0, BangBI[i + 2, 2], .)) ** 0.5; *BI SE;
									end;
								end;

								arms = {'Treatment, 3x2', 'Placebo, 3x2', 'Treatment, 5x2', 'Placebo, 5x2'};
							end;

						if length(&direction)= 0 | upcase(&direction) = ("TWOSIDED") then
							do;
								BangBI[,3] = BangBI[,1] - quantile('normal', 0.975) * BangBI[,2]; *lower CL;
								BangBI[,4] = BangBI[,1] + quantile('normal', 0.975) * BangBI[,2]; *upper CL;
								l = "Bang's BI, two-sided Confidence Interval (CI)";
							end;

						if upcase(&direction) = "LOWER" then
							do;
								BangBI[,3] = -1;
								BangBI[,4] = BangBI[,1] + quantile('normal', 0.95) * BangBI[,2];
								l = "Bang's BI, one-sided Confidence Interval (CI)";
							end;
						else if upcase(&direction) = "UPPER" then
							do;
								BangBI[,3] = BangBI[,1] - quantile('normal', 0.95) * BangBI[,2];
								BangBI[,4] = 1;
								l = "Bang's BI, one-sided Confidence Interval (CI)";
							end;

						tbl = TableCreate("Arm", arms);
						call TableAddVar(tbl, {'BI Estimate' 'Std Err' 'Lower 95% CL' 'Upper 95% CL'}, BangBI);
						call TableSetVarFormat(tbl, {'BI Estimate' 'Std Err' 'Lower 95% CL' 'Upper 95% CL'}, {'7.3' '7.3' '7.3' '7.3'});
						call TablePrint(tbl) ID = 'Arm' justify = {c c c c c} label = l;
					end;
				else
					do;
						print "ERROR: X has wrong structure to estimate Bang's BI.";
						stop "ERROR: X has wrong structure to estimate Bang's BI.";
					end;
			end;
	quit;
	*End of Bang BI;
%mend;

ods _all_ close; ods listing; options nodate nonumber pagesize=60 linesize=100 FORMCHAR='|_ _ ||||||+=|-/\<>*';

*Table III from James' 1996 paper;
%BI(%str({
41 27 22, 
66 72 36, 
30 24 64, 
44 51 52
}));

*Table V from James' 1996 paper;
%BI(%str({
145 34,	
71 59,	
76 38
}), direction='twosided');

%BI(%str({
145 34,	
71 59,	
76 38
}), direction='upper');

%BI(%str({
145 34,	
71 59,	
76 38
}), direction='lower');

*Table 4 from Bang's 2010 paper;
%BI(%str({
21 19,
0 4,
24 26
}));

*Table 5 from Bang's 2010 paper;
%BI(%str({
41 14,
55 99,
130 106
}));

*Table 7 from Bang's 2004 paper;
%BI(
%str({
82 27,
25 29,
170 83
}));

*Table 6 and 8 from Bang's 2004 paper;
%BI(
X=%str({
38 11,
44 16,
21 21,
4 8,
170 83
}), 
ANCILLARY=%str({
79 36,
86 45
}), direction='twosided'
);

*Table 6 from Bang's 2004 paper;
%BI(
X=%str({
38 11,
44 16,
21 21,
4 8,
170 83
}));

*Stata example, http://fmwww.bc.edu/RePEc/bocode/b/blinding.html;
%BI(
%str({
2 2,
5 4,
3 3,
4 5,
6 8
}));


*User may modify the weights;
%BI(
X=%str({
38 11,
44 16,
21 21,
4 8,
170 83
}),
JAMES_WEIGHTS=%str({
0 0.5,
0.5 0,
1 1
}),
BANG_WEIGHTS=%str({
1,
0.4,
-0.4,
-1,
0
}));
