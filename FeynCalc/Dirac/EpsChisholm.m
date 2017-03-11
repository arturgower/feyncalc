(* ::Package:: *)



(* :Title: EpsChisholm														*)

(*
	This software is covered by the GNU General Public License 3.
	Copyright (C) 1990-2016 Rolf Mertig
	Copyright (C) 1997-2016 Frederik Orellana
	Copyright (C) 2014-2016 Vladyslav Shtabovenko
*)

(* :Summary:  Applies the Chisholm identity backwards						*)

(* ------------------------------------------------------------------------ *)

EpsChisholm::usage =
"EpsChisholm[expr] substitutes for a gamma matrix contracted with \
a Levi Civita tensor (Eps) the Chisholm identity.";

(* ------------------------------------------------------------------------ *)

Begin["`Package`"]
End[]

Begin["`EpsChisholm`Private`"]

esVerbose::usage="";
eeps::usage="";

Options[EpsChisholm] = {
	DiracTrick -> True,
	FCE -> False,
	FCI -> False,
	FCVerbose -> False
};



EpsChisholm[expr_, OptionsPattern[]] :=
	Block[ {new = 0,ex,terms,rest,res, holdDOT, eps, freePart, dsPart, diracObjects,
			diracObjectsEval, null1, null2, dsHead, time, repRule},

		If [OptionValue[FCVerbose]===False,
			esVerbose=$VeryVerbose,
			If[MatchQ[OptionValue[FCVerbose], _Integer?Positive | 0],
				esVerbose=OptionValue[FCVerbose]
			];
		];

		FCPrint[1, "EpsChisholm: Entering EpsChisholm", FCDoControl->esVerbose];
		FCPrint[3, "EpsChisholm: Entering with, ", expr , FCDoControl->esVerbose];

		If[ OptionValue[FCI],
			ex = expr,
			ex = FCI[expr]
		];

		If[	FreeQ2[ex,{DiracGamma,Eps}],
			Return[ex]
		];


		(* This is the normal mode which works well both for large and small expressions *)
		FCPrint[1, "EpsChisholm: Normal mode.", FCDoControl->esVerbose];
		time=AbsoluteTime[];
		FCPrint[1, "EpsChisholm: Extracting Dirac objects.", FCDoControl->esVerbose];
		ex = FCDiracIsolate[ex,FCI->True,Head->dsHead, DiracGammaCombine->False, LorentzIndex->True];
		ex = ex /. h_dsHead/; FreeQ[h,Eps] :> Identity@@h;


		{freePart,dsPart} = FCSplit[ex,{dsHead}];
		FCPrint[3,"EpsChisholm: dsPart: ",dsPart , FCDoControl->esVerbose];
		FCPrint[3,"EpsChisholm: freePart: ",freePart , FCDoControl->esVerbose];

		diracObjects = Cases[dsPart+null1+null2, dsHead[_], Infinity]//DeleteDuplicates//Sort;

		FCPrint[1, "EpsChisholm: Done extracting Dirac objects, timing: ", N[AbsoluteTime[] - time, 4], FCDoControl->esVerbose];

		time=AbsoluteTime[];

		diracObjectsEval = diracObjects/. Eps->eeps /. DOT->holdDOT //.
			{dsHead[m_. holdDOT[x__] eeps[a___, LorentzIndex[in_], b__]]/;!FreeQ[{x},in] :>
				(-1^Length[{b}]) dsHead[m eeps2[a, b, LorentzIndex[in]] holdDOT[x]]};

		diracObjectsEval = diracObjectsEval/.eeps2->eeps;

		diracObjectsEval = diracObjectsEval //. dsHead[m_. holdDOT[x___, DiracGamma[in_LorentzIndex],y___] eeps[a_,b_,c_,in_LorentzIndex]] :>
		(Conjugate[$LeviCivitaSign] I ( dsHead[m holdDOT[x,DiracGamma[a], DiracGamma[b], DiracGamma[c], DiracGamma[5],y]]
			- dsHead[m ExpandScalarProduct[Pair[a,b],FCI->True] holdDOT[x,DiracGamma[c],DiracGamma[5],y]]
			- dsHead[m ExpandScalarProduct[Pair[b,c],FCI->True] holdDOT[x,DiracGamma[a].DiracGamma[5],y]]
			+ dsHead[m ExpandScalarProduct[Pair[a,c],FCI->True] holdDOT[x,DiracGamma[b],DiracGamma[5],y]]));

		time=AbsoluteTime[];
		FCPrint[1, "EpsChisholm: Inserting Dirac objects back.", FCDoControl->esVerbose];

		diracObjectsEval = diracObjectsEval /. holdDOT->DOT /. dsHead->Identity /. eeps->Eps;
		repRule = MapThread[Rule[#1,#2]&,{diracObjects,diracObjectsEval}];
		FCPrint[3,"EpsChisholm: repRule: ",repRule , FCDoControl->esVerbose];
		res = freePart + ( dsPart/.repRule);
		FCPrint[1, "EpsChisholm: Done inserting Dirac objects back, timing: ", N[AbsoluteTime[] - time, 4], FCDoControl->esVerbose];
		FCPrint[3,"EpsChisholm: Intermediate result: ", res, FCDoControl->esVerbose];

		If[	OptionValue[DiracTrick],
				time=AbsoluteTime[];
				FCPrint[1, "EpsChisholm: Applying DiracTrick.", FCDoControl->esVerbose];
				res = DiracTrick[res, FCI->True];
				FCPrint[1, "EpsChisholm: Done applying DiracTrick,timing: ", N[AbsoluteTime[] - time, 4], FCDoControl->esVerbose]
		];

		FCPrint[1, "EpsChisholm: Leaving.", FCDoControl->esVerbose];
		FCPrint[3, "EpsChisholm: Leaving with ", res, FCDoControl->esVerbose];

		If[ OptionValue[FCE],
			res = FCE[res]
		];



		FCPrint[3, "EpsChisholm: Leaving with: ", res , FCDoControl->esVerbose];
		FCPrint[3, "EpsChisholm: Leaving. ", res , FCDoControl->esVerbose];

		res
	]

FCPrint[1,"EpsChisholm.m loaded."];
End[]
