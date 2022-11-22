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

NOTE: for James' BI, X may have two treatment arms:
                 |                Assignment                  |
                 |--------------------------------------------|
     Guess       |Treatment, dose1| Treatment, dose2| Placebo |
-----------------|----------------------------------|---------|
Treatment, dose1 |       n11   	  |       n12       |	n13   |         |n11 n12 n13|
Treatment, dose2 |       n21   	  |       n22       |	n23   | --> X = |n21 n22 n23|
Placebo          |       n31   	  |       n32       |	n33   |         |n31 n32 n33|
Don't Know       |       n41   	  |       n42       |	n43   |         |n41 n42 n43|

NOTE: for Bang's BI, X may have five levels of guessing.
	  In this case an ancillary table for the subjects who answered Don't Know should be provided.
	  To estimate James BI, Strongly Believe Treatment & Somewhat Believe Treatment aggregated as Treatment,
	  Somewhat Believe Treatment & Strongly Believe Placebo aggregated as Placebo: 5x2 matrix will be transformed into 3x2 matrix.

5x2 matrix structure:
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


direction is an option to specify a type of the confidence limits:

DIRECTION = 'twosided' - to speicy two-sided 95% confidence limits -- DEFAULT
DIRECTION = 'less'	   - to specify lef-sided 95% confidence limits
DIRECTION = 'greater'  - to specify right-sided 95% confidence limits
;

%macro BI(X, ANCILLARY=%str({}), DIRECTION='TWOSIDED');
	title;
	footnote;

	*James BI: 0 = complete lack of blinding, 0.5 = random guessing, 1 = complete blinding (all report Dont Know);
	proc iml;
		x = &X;
		nrowX = nrow(x);
		ncolX = ncol(x);

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
				print 'James Blinding Index (BI)';

				WeightsDef=Weights[,1]`;
				rows = {'Weights'};
				cols = {'Correct Guess' 'Wrong Guess' 'Dont Know'};
				mattrib WeightsDef rowname = (rows) colname =(cols) label = {'James BI: Weights and Definitions'};
				print (WeightsDef);
			end;
		else if nrowX = 4 then
			do;
				Weights={ 0 0.5 0.75, 0.5 0 0.75, 0.75 0.75 0, 1 1 1 };
				print 'James Blinding Index (BI)';

				WeightsDef=Weights[,1]`;
				rows = {'Weights'};
				cols = {'Correct Guess' 'Correct Treatment, Wrong Dose'  'Wrong Treatment' 'Dont Know'};
				mattrib WeightsDef rowname = (rows) colname =(cols) label = {'James BI: Weights and Definitions'};
				print (WeightsDef);
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

		do i=1 to (nrow(P) - 2);
			do j=1 to (ncol(P) - 1);
				Pdo = Pdo + ((Weights[i, j] * P[i, j]) / (1 - Pdk));
				Pde = Pde + ((Weights[i, j] * P[i, ncol(P)] * (P[nrow(P), j] - P[nrow(P) - 1, j])) / (1 - Pdk) ** 2);
				denom = denom + Weights[i, j] * P[i, ncol(P)] * (P[nrow(P), j] - P[nrow(P) - 1, j]);
			end;
		end;

		denom = 4 * denom ** 2;
		Kd = (Pdo - Pde) / Pde;
		JamesBI = j(1, 4, .);
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

		if length(&direction)= 0 | upcase(&direction)= ("TWOSIDED") then
			do;
				JamesBI[1,3] = JamesBI[1,1] - quantile('normal', 0.975) * JamesBI[1,2];
				JamesBI[1,4] = JamesBI[1,1] + quantile('normal', 0.975) * JamesBI[1,2];
				mattrib JamesBI rowname={'Overall'} colname={'BI Estimate' 'SE' 'Lower 95% CL' 'Upper 95% CL'} label={'James BI, two-sided CL'} format=7.3;
			end;

		if upcase(&direction)= "LESS" then
			do;
				JamesBI[1,3] = 0;
				JamesBI[1,4] = JamesBI[1,1] + quantile('normal', 0.95) * JamesBI[1,2];
				mattrib JamesBI rowname={'Overall'} colname={'BI Estimate' 'SE' 'Lower 95% CL' 'Upper 95% CL'} label={'James BI, one-sided CL'} format=7.3;
			end;

		else if upcase(&direction) = "GREATER" then
			do;
				JamesBI[1,3] = JamesBI[1,1] - quantile('normal', 0.95) * JamesBI[1,2];
				JamesBI[1,4] = 1;
				mattrib JamesBI rowname={'Overall'} colname={'BI Estimate' 'SE' 'Lower 95% CL' 'Upper 95% CL'} label={'James BI, one-sided CL'} format=7.3;
			end;

		print JamesBI;
	quit;
	*End of James BI;

	*Bang BI: -1 = opposite guessing, 0 = perfect blinding, 1 = complete lack of blinding;
	proc iml;
		x = &X;
		a = &ANCILLARY;
		nrowX = nrow(x);

		if nrowX = 3 | nrowX = 5 then
			do;
				print 'Bang Blinding Index (BI) - each arm assesed separately';
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
					1 	 = strongly believe treatment
					0.5  = somewhat believe treatment
					-0.5 = somewhat believe placebo
					-1 	 = strongly believe placebo
					0.25 = ancillary, treatment
					-0.25= ancillary, placebo;

				*3x2;
				if nrowX = 3 | nrowX32 = 3 then
					do;
						if nrowX32 = 0 then
							x32 = x;
						N = x32[+];
						nrowX32 = nrow(x32);
						ncolX32 = ncol(x32);
						rowTot32 = x32[,+];
						x32 = insert(x32, rowTot32, 0, ncolX32 + 1);
						colTot32 = x32[+,];
						x32 = insert(x32, colTot32, nrowX32 + 1);
						x32 = x32`;

						do i=1 to 2;
							BangBI[i,1] = (2 * (x32[i, i] / (x32[i, 1] + x32[i, 2])) - 1) * ((x32[i, 1] + x32[i, 2]) / (x32[i, 1] + x32[i, 2] + x32[i, 3]));	*BI est;
							BangBI[i,2] = sqrt(((x32[i, 1] / x32[i, ncol(x32)]) * (1 - (x32[i, 1] / x32[i, ncol(x32)])) +
								(x32[i, 2] / x32[i, ncol(x32)]) * (1 - (x32[i, 2] / x32[i, ncol(x32)])) +
								2 * (x32[i, 1] / x32[i, ncol(x32)]) * (x32[i, 2] / x32[i, ncol(x32)])) / x32[i, ncol(x32)]);	*BI SE;
						end;

						if nrowX = 3 & IsEmpty(a) = 1 then 
							do;
								WeightsDef = {1 -1 0};
								rows = {'Weights'};
								cols = {'Treatment' 'Placebo' 'Dont Know'};
								mattrib WeightsDef rowname = (rows) colname =(cols) label = {'Bang BI: Weights and Definitions'};
								print WeightsDef;
							end;
					end;

				*5x2 with a 2x2 ancillary;
				if nrowX = 5 & IsEmpty(a) = 0 then
					do;
						Weights = {1, 0.5, -0.5, -1, 0.25, -0.25};
						WeightsDef=Weights`;
						rows = {'Weights'};
						cols = {'Strongly believe treatment' 'Somewhat believe treatment' 'Somewhat believe placebo' 'Strongly believe placebo'
							'Second guess - treatment' 'Second guess - placebo'};
						mattrib WeightsDef rowname = (rows) colname =(cols) label = {'Bang BI: Weights and Definitions'};

						print WeightsDef;
						colTot = x[+,];

						*remove Dont Know row;
						x = x[1:4,];

						*modify the second column in x and a matrices;
						x1 = x[,1];
						x2 = x[4:1,2];
						x = x1||x2;
						a1 = a[,1];
						a2 = a[2:1,2];
						a = a1||a2;

						*combine  matrices x and a;
						x = x // a;

						*create empty matrices;
						P  = j(6, 2, .);
						Q  = j(6, 2, 1);
						WP = j(5, 2, .);
						W2P = j(6, 2, .);

						do i=1 to ncol(x);
							P[, i]  = x[, i] / colTot[1, i];
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
								BangBI[i + 2, 2] = ((coltotW2P[1, i] + colTotWP[1, i]) / colTot[1, i]) ** 0.5;	*BI SE;
							end;
						end;
					end;

				*5x2 without a 2x2 ancillary;
				if nrowX = 5 & IsEmpty(a) = 1 then
					do;
						Weights = {1, 0.5, -0.5, -1, 0};
						print 'No ancillary table';
						WeightsDef=Weights`;
						rows = {'Weights'};
						cols = {'Strongly believe treatment' 'Somewhat believe treatment' 'Somewhat believe placebo' 'Strongly believe placebo' 'Dont Know'};
						mattrib WeightsDef rowname = (rows) colname =(cols) label = {'Bang BI: Weights and Definitions'};

						print WeightsDef;
						colTot = x[+,];

						*create empty matrices;
						P  = j(5, 2, .);
						Q  = j(5, 2, 1);
						WP = j(5, 2, .);
						W2P = j(5, 2, .);

						do i=1 to ncol(x);
							P[, i]  = x[, i] / colTot[1, i];
							Q[, i] = Q[, i] - P[, i];
						end;

						do i = 1 to ncol(x);
							if i = ncol(x) then Weights = -1 * Weights;
							do j = 1 to nrow(x)-1;
								WP[j,i] = 2 * (Weights[j, 1] * Weights[(j+1) : nrow(x), 1])` * P[j, i] * P[(j+1) : nrow(x), i];
							end;
						end;

						colTotWP = WP[+,];

						Weights = -1 * Weights;

						do i=1 to 2;
							if i = ncol(x) then Weights = -1 * Weights;
							BangBI[i+2, 1] = x[, i]` * Weights / colTot[1, i];

							*BI est;
							do j = 1 to nrow(x);
								W2P[j, i] = Weights[j, 1] ## 2 * P[j, i] * Q[j, i];
								coltotW2P = W2P[+,];
								BangBI[i+2, 2] = ((coltotW2P[1, i] + colTotWP[1, i]) / colTot[1, i]) ** 0.5;	*BI SE;
							end;
						end;
					end;


				if length(&direction)= 0 | upcase(&direction)= ("TWOSIDED") then
					do;
						BangBI[,3] = BangBI[,1] - quantile('normal', 0.975) * BangBI[,2];	*lower CL;
						BangBI[,4] = BangBI[,1] + quantile('normal', 0.975) * BangBI[,2];	*upper CL;
						mattrib BangBI rowname = {'Treatment, 3x2' 'Placebo, 3x2' 'Treatment, 5x2' 'Placebo, 5x2'} 
							colname = {'BI Estimate' 'SE' 'Lower 95% CL' 'Upper 95% CL'}
							label = {'Bang BI, two-sided CL'} format = 7.3;
					end;

				if upcase(&direction)= "LESS" then
					do;
						BangBI[,3] = -1;
						BangBI[,4] = BangBI[,1] + quantile('normal', 0.95) * BangBI[,2];
						mattrib BangBI rowname = {'Treatment, 3x2' 'Placebo, 3x2' 'Treatment, 5x2' 'Placebo, 5x2'} 
							colname = {'BI Estimate' 'SE' 'Lower 95% CL' 'Upper 95% CL'}
							label = {'Bang BI, one-sided CL'} format = 7.3;
					end;
				else if upcase(&direction) = "GREATER" then
					do;
						BangBI[,3] = BangBI[,1] - quantile('normal', 0.95) * BangBI[,2];
						BangBI[,4] = 1;
						mattrib BangBI rowname = {'Treatment, 3x2' 'Placebo, 3x2' 'Treatment, 5x2' 'Placebo, 5x2'} 
							colname = {'BI Estimate' 'SE' 'Lower 95% CL' 'Upper 95% CL'}
							label = {'Bang BI, one-sided CL'} format = 7.3;
					end;

				print BangBI;
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

/*ods listing; options nodate nonumber pagesize=40 linesize=64 FORMCHAR='|_ _ ||||||+=|-/\<>*';*/

*Table III from James' 1996 paper;
%BI(%str({
41 27 22, 
66 72 36, 
30 24 64, 
44 51 52
}), direction='twosided');

*Table V from James' 1996 paper;
%BI(%str({
145 34,	
71 59,	
76 38
}));

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
