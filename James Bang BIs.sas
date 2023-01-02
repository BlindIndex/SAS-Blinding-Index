*
James and Bang BIs are to access effectiveness of blinding in clinical trials.

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


NOTE: for James' BI, X may have two treatment arms:
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

Note: the sum of Bang's weigths must be zero.

DIRECTION is an option to specify a type of the confidence limits:

DIRECTION = 'twosided' - to speicy two-sided 95% confidence limits -- DEFAULT
DIRECTION = 'lower'	   - to specify lef-sided 95% confidence limits
DIRECTION = 'upper'  - to specify right-sided 95% confidence limits
;

%macro BI(X, ANCILLARY=%str({}), JAMES_WEIGHTS=%str({}), BANG_WEIGHTS=%str({}), DIRECTION='TWOSIDED');
	title;
	footnote;
	dm 'odsresults; clear';

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
		define header SpanHeader;            /* define spanning header */
			text "Treatment Assignment, 5x2";     /* title of spanning header */
			start = Treatment;                  /* span starts at second column */
			end   = Placebo;                  /* span ends at third column */
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



	*James BI: 0 = complete lack of blinding, 0.5 = random guessing, 1 = complete blinding (all report Dont Know);
	proc iml;
		x = &X;
		nrowX = nrow(x);
		ncolX = ncol(x);
		JAMES_WEIGHTS = &JAMES_WEIGHTS;

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

		*Weights assignment:
		0 	 = correct guess
		0.5  = correct treatment, wrong dose
		0.75 = wrong treatment
		1 	 = dont know;

		if nrowX = 3 then
			do;
				Weights={ 0 0.75, 0.75 0, 1 1 };
				if IsEmpty(JAMES_WEIGHTS) = 0 then 
					do;
						nrowJAMES_WEIGHTS = nrow(JAMES_WEIGHTS);
						ncolJAMES_WEIGHTS = ncol(JAMES_WEIGHTS);
						if nrowJAMES_WEIGHTS = 3 & ncolJAMES_WEIGHTS = 2 then Weights = JAMES_WEIGHTS;
						else
							do;
								print 'ERROR: James weights have wrong structure';
								stop;
								abort;
							end;
					end;

				print 'James Blinding Index (BI): ranges from 0 to 1';

				assignment = x[1:3, 1:2];

				vars = {'Treatment', 'Placebo', 'Dont Know'};
				tbl = TableCreate("Guess", vars);
				call TableAddVar(tbl, {'Treatment' 'Placebo'}, assignment);
				call TablePrint(tbl) template="Custom1";

				x22 = x[1:2, 1:2];
				Tot22 = x22[+];

				WeightsDef=Weights[,1]`;

				vars = {'Weight'};
				tbl = TableCreate('_', vars);
				call TableAddVar(tbl, {'Correct Guess' 'Wrong Guess' 'Dont Know'}, WeightsDef); 
				call TablePrint(tbl) ID = '_' justify = {c c c c} label = 'James BI: Weights and Definitions';

			end;
		else if nrowX = 4 then
			do;
				Weights={ 0 0.5 0.75, 0.5 0 0.75, 0.75 0.75 0, 1 1 1 };
				if IsEmpty(JAMES_WEIGHTS) = 0 then 
					do;
						nrowJAMES_WEIGHTS = nrow(JAMES_WEIGHTS);
						ncolJAMES_WEIGHTS = ncol(JAMES_WEIGHTS);
						if nrowJAMES_WEIGHTS = 4 & ncolJAMES_WEIGHTS = 3 then Weights = JAMES_WEIGHTS;
						else
							do;
								print 'ERROR: James weights have wrong structure';
								stop;
								abort;
							end;
					end;

				print 'James Blinding Index (BI): ranges from 0 to 1';

				assignment = x[1:4, 1:3];

				vars = {'Treatment, Dose 1', 'Treatment, Dose 2', 'Placebo', 'Dont Know'};
				tbl = TableCreate("Guess", vars);
				call TableAddVar(tbl, {'Treatment1' 'Treatment2' 'Placebo'}, assignment);
				call TablePrint(tbl) template="Custom2";

				x32 = x[1:3, 1:2];
				Tot22=x32[+];

				WeightsDef=Weights[,1]`;

				vars = {'Weight'};
				tbl = TableCreate('_', vars);
				call TableAddVar(tbl, {'Correct Guess' 'Correct Treatment, Wrong Dose'  'Wrong Treatment' 'Dont Know'}, WeightsDef); 
				call TablePrint(tbl) ID = '_' justify = {c c c c c} label = 'James BI: Weights and Definitions';

			end;
		else if nrowX >< 5 then
			do;
				print 'ERROR: X has wrong structure to estimate James BI';
				stop;
				abort;
			end;

		P = x / max(x);
		Pdk = P[nrow(P) - 1, ncol(P)];
		Pdo = 0;
		Pde = 0;
		denom = 0;

		JamesBI = j(1, 4, .);

		if Tot22 > 0 then do;
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
		else if Tot22 = 0 then do;
			JamesBI[1, 1] = 1;
			JamesBI[1, 2] = 0;
		end;

		message = {''};
		if length(&direction)= 0 | upcase(&direction)= ("TWOSIDED") then
			do;
				JamesBI[1, 3] = JamesBI[1, 1] - quantile('normal', 0.975) * JamesBI[1, 2];
				JamesBI[1, 4] = JamesBI[1, 1] + quantile('normal', 0.975) * JamesBI[1, 2];
				if JamesBI[1, 1] ^= 1 & JamesBI[1, 1] ^= 0 then do;
					if JamesBI[1, 4] < 0.5 then int = {'unblinding may be claimed (0.5 is not in 95% CI)'};
					else if 0.5 < JamesBI[1, 3] then int = {'unblinding may be claimed (0.5 is not in 95% CI)'};
					else int = {};
				end;
				else if JamesBI[1, 1] = 1 then int = {'complete blinding'};
				else if JamesBI[1, 1] = 0 then int = {'complete unblinding'};
				l = 'James BI, two-sided Confidence Inetrval (CI)';
			end;

		if upcase(&direction)= "LOWER" then
			do;
				JamesBI[1, 3] = 0;
				JamesBI[1, 4] = JamesBI[1, 1] + quantile('normal', 0.95) * JamesBI[1, 2];
				l = 'James BI, one-sided Confidence Interval (CI)';
			end;

		else if upcase(&direction) = "UPPER" then
			do;
				JamesBI[1, 3] = JamesBI[1, 1] - quantile('normal', 0.95) * JamesBI[1, 2];
				JamesBI[1, 4] = 1;
				l = 'James BI, one-sided Confidence Interval (CI)';
			end;

		if IsEmpty(int) = 1 then do;
			vars = {'Overall'};
			tbl = TableCreate("Type", vars);
			call TableAddVar(tbl, {'BI Estimate' 'StdErr' 'Lower 95% CL' 'Upper 95% CL'}, JamesBI);
			call TableSetVarFormat(tbl, {'BI Estimate' 'StdErr' 'Lower 95% CL' 'Upper 95% CL'}, {'7.3' '7.3' '7.3' '7.3'});
			call TablePrint(tbl) ID = 'Type' justify = {c c c c c} label = l;
		end;
		else do;
			vars = {'Overall'};
			tblint = TableCreate('Interpretation', int);
			tbl = TableCreate("Type", vars);
			call TableAddVar(tbl, {'BI Estimate' 'StdErr' 'Lower 95% CL' 'Upper 95% CL' }, JamesBI);
			tbl = tbl || tblint;
			call TableSetVarFormat(tbl, {'BI Estimate' 'StdErr' 'Lower 95% CL' 'Upper 95% CL'}, {'7.3' '7.3' '7.3' '7.3'});
			call TablePrint(tbl) ID = 'Type' justify = {c c c c c c} label = l;
		end;

	*End of James BI;

print '----------------------------------------------------------------';

	*Bang BI: -1 = opposite guessing, 0 = perfect blinding, 1 = complete lack of blinding;

		x = &X;
		a = &ANCILLARY;
		nrowX = nrow(x);
		BANG_WEIGHTS = &BANG_WEIGHTS;
		if IsEmpty(BANG_WEIGHTS) = 0 then BANG_WEIGHTScolTot = round(sum(BANG_WEIGHTS), 0.00000001);

		if nrowX = 3 | nrowX = 5 then
			do;
				print 'Bang Blinding Index (BI): ranges from -1 to 1 - each treatment arm assessed separately';
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

				*Weights assignment:
					1     = strongly believe treatment
					0.5   = somewhat believe treatment
					-0.5  = somewhat believe placebo
					-1    = strongly believe placebo
					0.25  = ancillary, treatment
					-0.25 = ancillary, placebo;

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
							if colTot22[1,i] > 0 then BangBI[i,1] = (2 * (x32[i, i] / (x32[i, 1] + x32[i, 2])) - 1) * ((x32[i, 1] + x32[i, 2]) / 
								(x32[i, 1] + x32[i, 2] + x32[i, 3]));	*BI est;
							BangBI[i,2] = sqrt(((x32[i, 1] / x32[i, ncol(x32)]) * (1 - (x32[i, 1] / x32[i, ncol(x32)])) +
								(x32[i, 2] / x32[i, ncol(x32)]) * (1 - (x32[i, 2] / x32[i, ncol(x32)])) +
								2 * (x32[i, 1] / x32[i, ncol(x32)]) * (x32[i, 2] / x32[i, ncol(x32)])) / x32[i, ncol(x32)]);	*BI SE;
						end;

						WeightsDef = {1 -1 0};
						assignment = assignment || WeightsDef`;

						vars = {'Treatment', 'Placebo', 'Dont Know'};
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
								if nrowBANG_WEIGHTS = 6 & ncolBANG_WEIGHTS = 1 & BANG_WEIGHTScolTot = 0 then Weights = BANG_WEIGHTS;
								else
									do;
										print 'ERROR: Bang weights have wrong structure or their sum is not zero';
										stop;
										abort;
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
						call TablePrint(tbl) template="Custom4";

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
							BangBI[i + 2, 1] = x[, i]` * Weights / colTot[1, i];  *BI est;
							do j = 1 to nrow(x);
								W2P[j, i] = Weights[j, 1] ## 2 * P[j, i] * Q[j, i];
								coltotW2P = W2P[+,];
								BangBI[i + 2, 2] = (coltotW2P[1, i] + colTotWP[1, i]) / colTot[1, i];	*BI SE;
								BangBI[i + 2, 2] = (choose(BangBI[i + 2, 2] >= 0, BangBI[i + 2, 2], .)) ** 0.5;	*BI SE;
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
								if nrowBANG_WEIGHTS = 5 & ncolBANG_WEIGHTS = 1 & BANG_WEIGHTScolTot = 0 then Weights = BANG_WEIGHTS;
								else
									do;
										print 'ERROR: Bang weights have wrong structure or their sum is not zero';
										stop;
										abort;
									end;
							end;

						print 'No ancillary table';

						assignment = x || Weights;

						vars = {'Strongly Believe Treatment', 'Somewhat Believe Treatment', 'Somewhat Believe Placebo', 'Strongly Believe Placebo', 'Dont Know'};
						tbl = TableCreate("Guess", vars);
						call TableAddVar(tbl, {'Treatment' 'Placebo' 'Weights'}, assignment);
						call TablePrint(tbl) template="Custom4";

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
							if i = ncol(x) then Weights = -1 * Weights;
							do j = 1 to nrow(x)-1;
								WP[j, i] = 2 * (Weights[j, 1] * Weights[(j + 1) : nrow(x), 1])` * P[j, i] * P[(j + 1) : nrow(x), i];
							end;
						end;

						colTotWP = WP[+,];

						Weights = -1 * Weights;

						do i=1 to 2;
							if i = ncol(x) then Weights = -1 * Weights;
							BangBI[i + 2, 1] = x[, i]` * Weights / colTot[1, i];	*BI est;

							do j = 1 to nrow(x);
								W2P[j, i] = Weights[j, 1] ## 2 * P[j, i] * Q[j, i];
								coltotW2P = W2P[+,];
								BangBI[i + 2, 2] = (coltotW2P[1, i] + colTotWP[1, i]) / colTot[1, i];	*BI SE;
								BangBI[i + 2, 2] = (choose(BangBI[i + 2, 2] >= 0, BangBI[i + 2, 2], .)) ** 0.5;	*BI SE;
							end;
						end;
						arms = {'Treatment, 3x2', 'Placebo, 3x2', 'Treatment, 5x2', 'Placebo, 5x2'};
					end;

				d = {0 0};

				if length(&direction)= 0 | upcase(&direction) = ("TWOSIDED") then
					do;
						BangBI[,3] = BangBI[,1] - quantile('normal', 0.975) * BangBI[,2];	*lower CL;
						BangBI[,4] = BangBI[,1] + quantile('normal', 0.975) * BangBI[,2];	*upper CL;

						if BangBI[1, 1] = -1 then BI1 = {'opposite guessing'};
						else if BangBI[1, 1] = 1 then BI1 = {'complete unblinding'};
						else if -0.2 <= BangBI[1, 1] & BangBI[1, 1] <= 0.2 then BI1 = {'blinding may be claimed successful (-0.2 <= BI <= 0.2)'};
						else BI1 = {' '};

						if BangBI[2, 1]  = -1 then BI2 = {'opposite guessing'};
						else if BangBI[2, 1] = 1 then BI2 = {'complete unblinding'};
						else if -0.2 <= BangBI[2, 1] & BangBI[2, 1] <= 0.2 then BI2 = {'blinding may be claimed successful (-0.2 <= BI <= 0.2)'};
						else BI2 = {' '};

						d = dimension(BangBI);

						if d[1, 1] > 2 then do;
							if BangBI[3, 1] = 1 then BI3 = {'opposite guessing'};
							else if BangBI[3, 1] = 1 then BI3 = {'complete unblinding'};
							else if -0.2 <= BangBI[3, 1] & BangBI[3, 1] <= 0.2 then BI3 = {'blinding may be claimed successful (-0.2 <= BI <= 0.2)'};
							else BI3 = {' '};

							if BangBI[4, 1] = 1 then BI4 = {'opposite guessing'};
							else if BangBI[4, 1] = 1 then BI4 = {'complete unblinding'};
							else if -0.2 <= BangBI[4, 1] & BangBI[4, 1] <= 0.2 then BI4 = {'blinding may be claimed successful (-0.2 <= BI <= 0.2)'};
							else BI4 = {' '};

							if BI1[1, 1] ^= ' ' | BI2[1, 1] ^= ' ' | BI3[1, 1] ^= ' ' | BI4[1, 1] ^= ' ' then int = BI1 // BI2 // BI3 // BI4;
							else int = {};
						end;
						else if BI1[1, 1] ^= ' ' | BI2[1, 1] ^= ' ' then int =  BI1 // BI2;
						else int = {};
						l = 'Bang BI, two-sided Confidence Interval (CI)';
					end;

				if upcase(&direction)= "LOWER" then
					do;
						BangBI[,3] = -1;
						BangBI[,4] = BangBI[,1] + quantile('normal', 0.95) * BangBI[,2];

						if BangBI[1, 4] < 0 then BI1 = {'unblinding may be claimed (0 is not in 95% CI)'};
						else BI1 = {' '};
						if BangBI[2, 4] < 0 then BI2 = {'unblinding may be claimed (0 is not in 95% CI)'};
						else BI2 = {' '};

						d = dimension(BangBI);

						if d[1, 1] > 2 then do;
							if BangBI[3, 4] < 0 then BI3 = {'unblinding may be claimed (0 is not in 95% CI)'};
							else BI3 = {' '};
							if BangBI[4, 4] < 0 then BI4 = {'unblinding may be claimed (0 is not in 95% CI)'};
							else BI4 = {' '};
							if BI1[1, 1] ^= ' ' | BI2[1, 1] ^= ' ' | BI3[1, 1] ^= ' ' | BI4[1, 1] ^= ' ' then int = BI1 // BI2 // BI3 // BI4;
							else int = {};
						end;
						else if BI1[1, 1] ^= ' ' | BI2[1, 1] ^= ' ' then int =  BI1 // BI2;
						else int = {};
						l = 'Bang BI, one-sided Confidence Interval (CI)';
					end;

				else if upcase(&direction) = "UPPER" then
					do;
						BangBI[,3] = BangBI[,1] - quantile('normal', 0.95) * BangBI[,2];
						BangBI[,4] = 1;

						if 0 < BangBI[1, 3] then BI1 = {'unblinding may be claimed (0 is not in 95% CI)'};
						else BI1 = {' '};
						if 0 < BangBI[2, 3] then BI2 = {'unblinding may be claimed (0 is not in 95% CI)'};
						else BI2 = {' '};

						d = dimension(BangBI);

						if d[1, 1] > 2 then do;
							if 0 < BangBI[3, 3] then BI3 = {'unblinding may be claimed (0 is not in 95% CI)'};
							else BI3 = {' '};
							if 0 < BangBI[4, 3] then BI4 = {'unblinding may be claimed (0 is not in 95% CI)'};
							else BI4 = {' '};
							if BI1[1, 1] ^= ' ' | BI2[1, 1] ^= ' ' | BI3[1, 1] ^= ' ' | BI4[1, 1] ^= ' ' then int = BI1 // BI2 // BI3 // BI4;
							else int = {};
						end;
						else if BI1[1, 1] ^= ' ' | BI2[1, 1] ^= ' ' then int =  BI1 // BI2;
						else int = {};
						l = 'Bang BI, one-sided Confidence Interval (CI)';
					end;

				if IsEmpty(int) = 1 then do;
					tbl = TableCreate("Arm", arms);
					call TableAddVar(tbl, {'BI Estimate' 'StdErr' 'Lower 95% CL' 'Upper 95% CL'}, BangBI);
					call TableSetVarFormat(tbl, {'BI Estimate' 'StdErr' 'Lower 95% CL' 'Upper 95% CL'}, {'7.3' '7.3' '7.3' '7.3'});
					call TablePrint(tbl) ID = 'Arm' justify = {c c c c c} label = l;
				end;
				else do;
					tblint = TableCreate('Interpretation', int);
					tbl = TableCreate("Arm", arms);
					call TableAddVar(tbl, {'BI Estimate' 'StdErr' 'Lower 95% CL' 'Upper 95% CL' }, BangBI);
					tbl = tbl || tblint;
					call TableSetVarFormat(tbl, {'BI Estimate' 'StdErr' 'Lower 95% CL' 'Upper 95% CL'}, {'7.3' '7.3' '7.3' '7.3'});
					call TablePrint(tbl) ID = 'Arm' justify = {c c c c c c} label = l;
				end;

			end;
		else
			do;
				print 'ERROR: X has wrong structure to estimate Bang BI';
				stop;
				abort;
			end;
	quit;
	*End of Bang BI;
%mend;


/*ods _all_ close; ods listing; options nodate nonumber pagesize=60 linesize=100 FORMCHAR='|_ _ ||||||+=|-/\<>*';*/

*Table III from James' 1996 paper;
%BI(%str({
41 27 22, 
66 72 36, 
30 24 64, 
44 51 52
}), direction='twosided');

*Table V from James' 1996 paper with interpretation;
%BI(%str({
145 34,	
71 59,	
76 38
}));
*with interpretation;
%BI(%str({
145 34,	
71 59,	
76 38
}), direction='upper');
*no interpretation;
%BI(%str({
145 34,	
71 59,	
76 38
}), direction='lower');

*James: Unblinding message for two-sided CL with interpretation;
%BI(%str({
179 0,	
41 89,	
76 38
}));

*Table 4 from Bang's 2010 paper with interpretation;
%BI(%str({
21 19,
0 4,
24 26
}));

*Table 5 from Bang's 2010 paper with interpretation;
%BI(%str({
41 14,
55 99,
130 106
}));

*Table 7 from Bang's 2004 paper with interpretation;
%BI(
%str({
82 27,
25 29,
170 83
}));

*Table 6 and 8 from Bang's 2004 paper with interpretation;
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

*Table 6 from Bang's 2004 paper with interpretation;
%BI(
X=%str({
38 11,
44 16,
21 21,
4 8,
170 83
}));

*Stata example, http://fmwww.bc.edu/RePEc/bocode/b/blinding.html with interpretation;
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

*testing special cases;
%BI(
%str({
0 27,
0 29,
170 83
}));

%BI(
%str({
82 0,
25 0,
170 83
}));

%BI(
%str({
0 0,
0 0,
170 83
}));

%BI(
%str({
0 0,
0 0,
0 0,
0 0,
170 83
}));

%BI(
%str({
0 0,
0 0,
0 0,
0 0,
170 83
}), 
ANCILLARY=%str({
79 36,
86 45
})
);

%BI(
%str({
60 50,
0 0,
20 15,
0 0,
170 83
}), 
ANCILLARY=%str({
79 36,
86 45
})
);
