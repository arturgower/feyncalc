(* ::Package:: *)

(* ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ *)

(* :Title: FeynCalc															*)

(*
	This software is covered by the GNU General Public License 3.
	Copyright (C) 1990-2018 Rolf Mertig
	Copyright (C) 1997-2018 Frederik Orellana
	Copyright (C) 2014-2018 Vladyslav Shtabovenko
*)

(* :Summary:	FeynCalc is a Mathematica package for symbolic evaluation
				of Feynman diagrams and algebraic calculations in quantum
				field theory and elementary particle physics.				*)

(* ------------------------------------------------------------------------ *)


If[ MemberQ[$Packages,"FeynCalc`"],
	Print[Style["FeynCalc is already loaded! To reload it, please restart the kernel.","Text", Red, Bold]];
	Abort[]
];

If[ ($VersionNumber < 8.0),
	Print[Style["You need at least Mathematica 8.0 to run FeynCalc. Evaluation aborted.",Red, Bold]];
	Abort[]
];

(*    Find out where FeynCalc is installed    *)
If[ !ValueQ[Global`$FeynCalcDirectory],
	(* By default FeynCalc is assumed to be located in the directory that contains FeynCalc.m *)
	FeynCalc`$FeynCalcDirectory = DirectoryName[$InputFileName],
	FeynCalc`$FeynCalcDirectory = Global`$FeynCalcDirectory
];
Remove[Global`$FeynCalcDirectory];

If[ FileNames["*",{FeynCalc`$FeynCalcDirectory}] === {},
	Print[Style["Could not find a FeynCalc installation. Evaluation aborted.",Red,Bold]];
	Clear[FeynCalc`$FeynCalcDirectory];
	Abort[];
];

(*    Set the version number    *)
FeynCalc`$FeynCalcVersion = "9.3.0";

If[ !ValueQ[Global`$FeynCalcStartupMessages],
	FeynCalc`$FeynCalcStartupMessages = True,
	FeynCalc`$FeynCalcStartupMessages = Global`$FeynCalcStartupMessages
];
Remove[Global`$FeynCalcStartupMessages];

If[ !ValueQ[Global`$LoadAddOns],
	FeynCalc`$LoadAddOns = {},
	FeynCalc`$LoadAddOns = Global`$LoadAddOns
];
Remove[Global`$LoadAddOns];

If[ ValueQ[Global`$LoadTARCER],
	Print[Style["$LoadTARCER is deprecated since FeynCalc 9.3, please use $LoadAddOns={\"TARCER\"} instead!",Red, Bold]];
	FeynCalc`$LoadAddOns = Join[FeynCalc`$LoadAddOns,{"TARCER"}]
];
Remove[Global`$LoadTARCER]

If[ !ValueQ[Global`$LoadPhi],
	(* Do not load Phi by default *)
	FeynCalc`$LoadPhi = False,
	FeynCalc`$LoadPhi = Global`$LoadPhi
];
Remove[Global`$LoadPhi]

If[ !ValueQ[Global`$LoadFeynArts],
	(* Do not load FeynArts by default *)
	FeynCalc`$LoadFeynArts = False,
	FeynCalc`$LoadFeynArts = Global`$LoadFeynArts
];
Remove[Global`$LoadFeynArts];

If[ !ValueQ[Global`$FAPatch],
	FeynCalc`$FAPatch = True,
	FeynCalc`$FAPatch = Global`$FAPatch
];
Remove[Global`$FAPatch]

If[ !ValueQ[Global`$FCAdvice],
	FeynCalc`$FCAdvice = True,
	FeynCalc`$FCAdvice = Global`$FCAdvice
];
Remove[Global`$FCAdvice]



If[ !ValueQ[Global`$RenameFeynCalcObjects],
	FeynCalc`$RenameFeynCalcObjects = {},
	FeynCalc`$RenameFeynCalcObjects = Global`$RenameFeynCalcObjects
];
Remove[Global`$RenameFeynCalcObjects];

If[ !ValueQ[Global`$FCCloudTraditionalForm],
	FeynCalc`$FCCloudTraditionalForm = True,
	FeynCalc`$FCCloudTraditionalForm = Global`$FCCloudTraditionalForm
];
Remove[Global`$FCCloudTraditionalForm];

If[ !ValueQ[FeynCalc`$FeynArtsDirectory],
	FeynCalc`$FeynArtsDirectory = FileNameJoin[{FeynCalc`$FeynCalcDirectory, "FeynArts"}]
];

(*    Load the configuration file    *)
If[ FileExistsQ[FileNameJoin[{FeynCalc`$FeynCalcDirectory,"FCConfig.m"}]],
	Get[FileNameJoin[{FeynCalc`$FeynCalcDirectory,"FCConfig.m"}]]
];

If[ FeynCalc`$FeynCalcStartupMessages=!=False,
	PrintTemporary[Style["Loading FeynCalc from "<>
	FeynCalc`$FeynCalcDirectory, "Text"]]
];

If[	TrueQ[FileExistsQ[FileNameJoin[{FeynCalc`$FeynCalcDirectory, ".testing"}]]],
	FeynCalc`$FeynCalcDevelopmentVersion = True,
	FeynCalc`$FeynCalcDevelopmentVersion = False
];

If[ !ValueQ[Global`$FCCheckContext],
	If[	TrueQ[FeynCalc`$FeynCalcDevelopmentVersion],
		FeynCalc`$FCCheckContext = True,
		FeynCalc`$FCCheckContext = False
	],
	FeynCalc`$FCCheckContext = Global`$FCCheckContext
];
Remove[Global`$FCCheckContext];



Global`globalContextBeforeLoadingFC = Names["Global`*"];

BeginPackage["FeynCalc`"];

FCDeclareHeader::usage =
"FCDeclareHeader is an internal FeynCalc function to declare
objects inside an .m file in the same manner as it is done in
the JLink package. It may be used by FeynCalc addons."

Begin["`Private`"]

FCDeclareHeader[file_, type_String:"file"] :=
	Module[ {strm, einput, moreLines = True},

		Switch[
			type,
			"file",
				strm = OpenRead[file],
			"string",
				strm = StringToStream[file],
			_,
			Print["FeynCalc: FCDeclareHeader: Unknown input type. Evaluation aborted"];
			Abort[];
		];

		If[ Head[strm] =!= InputStream,
			Return[$Failed]
		];
		While[
			moreLines,
			einput = Read[strm, Hold[Expression]];
			ReleaseHold[einput];
			If[ einput === $Failed || MatchQ[einput, Hold[_End]],
				moreLines = False
			]
		];
		Close[strm]
	];

End[]

(* need to do this first, otherwise $NonComm and $FCTensorList do not get built correctly *)
boostrappingList = Join[
	Map[ToFileName[{$FeynCalcDirectory,"Shared"},#]&, {"SharedTools.m", "DataType.m"}],
	Map[ToFileName[{$FeynCalcDirectory,"NonCommAlgebra"},#]&, {"NonCommutative.m"}],
	Map[ToFileName[{$FeynCalcDirectory,"Lorentz"},#]&, {"DeclareFCTensor.m"}]
];

listMain = {ToFileName[{$FeynCalcDirectory}, "FCMain.m"]};
listShared = FileNames[{"*.m"},ToFileName[{$FeynCalcDirectory,"Shared"}]];
listNonCommAlgebra = FileNames[{"*.m"},ToFileName[{$FeynCalcDirectory,"NonCommAlgebra"}]];
listLorentz = FileNames[{"*.m"},ToFileName[{$FeynCalcDirectory,"Lorentz"}]];
listDirac = FileNames[{"*.m"},ToFileName[{$FeynCalcDirectory,"Dirac"}]];
listPauli = FileNames[{"*.m"},ToFileName[{$FeynCalcDirectory,"Pauli"}]];
listSUN = FileNames[{"*.m"},ToFileName[{$FeynCalcDirectory,"SUN"}]];
listLoopIntegrals = FileNames[{"*.m"},ToFileName[{$FeynCalcDirectory,"LoopIntegrals"}]];
listFeynman = FileNames[{"*.m"},ToFileName[{$FeynCalcDirectory,"Feynman"}]];
listQCD = FileNames[{"*.m"},ToFileName[{$FeynCalcDirectory,"QCD"}]];
listTables = FileNames[{"*.m"},ToFileName[{$FeynCalcDirectory,"Tables"}]];
listExportImport = FileNames[{"*.m"},ToFileName[{$FeynCalcDirectory,"ExportImport"}]];
listMisc = FileNames[{"*.m"},ToFileName[{$FeynCalcDirectory,"Misc"}]];

fcSelfPatch[file_String]:=
	Block[{originalCode,repList},

		repList = Map[{
				Rule[RegularExpression["\\b" <> First[#] <> "\\b"], Last[#]],
				Rule[RegularExpression["\\_" <> First[#] <> "\\b"], "_" <> Last[#]],
				Rule[RegularExpression[First[#] <> "\\_\\b"], Last[#] <> "_"]} &, $RenameFeynCalcObjects] // Flatten;
		originalCode = Import[file, "Text"];
		StringReplace[originalCode, repList, MetaCharacters -> Automatic]
	];


AppendTo[$ContextPath, "FeynCalc`Package`"];



patchedMain=(fcSelfPatch/@listMain);
patchedShared=(fcSelfPatch/@listShared);

patchedBoostrap			=(fcSelfPatch/@boostrappingList)
patchedNonCommAlgebra	=(fcSelfPatch/@listNonCommAlgebra);
patchedLorentz			=(fcSelfPatch/@listLorentz)
patchedDirac			=(fcSelfPatch/@listDirac)
patchedPauli			=(fcSelfPatch/@listPauli)
patchedSUN				=(fcSelfPatch/@listSUN)
patchedLoopIntegrals	=(fcSelfPatch/@listLoopIntegrals)
patchedFeynman			=(fcSelfPatch/@listFeynman)
patchedQCD				=(fcSelfPatch/@listQCD)
patchedTables			=(fcSelfPatch/@listTables)
patchedExportImport		=(fcSelfPatch/@listExportImport)
patchedMisc				=(fcSelfPatch/@listMisc)


FCDeclareHeader[#,"string"]&/@(patchedMain);
ToExpression/@patchedMain;

FCDeclareHeader[#,"string"]&/@patchedShared;
FCDeclareHeader[#,"string"]&/@patchedNonCommAlgebra;
FCDeclareHeader[#,"string"]&/@patchedLorentz;
FCDeclareHeader[#,"string"]&/@patchedDirac;
FCDeclareHeader[#,"string"]&/@patchedPauli;
FCDeclareHeader[#,"string"]&/@patchedSUN;
FCDeclareHeader[#,"string"]&/@patchedLoopIntegrals;
FCDeclareHeader[#,"string"]&/@patchedFeynman;
FCDeclareHeader[#,"string"]&/@patchedQCD;
FCDeclareHeader[#,"string"]&/@patchedTables;
FCDeclareHeader[#,"string"]&/@patchedExportImport;
FCDeclareHeader[#,"string"]&/@patchedMisc;

ToExpression/@patchedBoostrap;
ToExpression/@patchedShared;
ToExpression/@patchedNonCommAlgebra;
ToExpression/@patchedLorentz;
ToExpression/@patchedDirac;
ToExpression/@patchedPauli;
ToExpression/@patchedSUN;
ToExpression/@patchedLoopIntegrals;
ToExpression/@patchedFeynman;
ToExpression/@patchedQCD;
ToExpression/@patchedTables;
ToExpression/@patchedExportImport;
ToExpression/@patchedMisc;

EndPackage[];

Remove["FeynCalc`boostrappingList"];
Remove["FeynCalc`fcSelfPatch"];
Remove["FeynCalc`list*"];
Remove["FeynCalc`patched*"];
Remove["FeynCalc`originalCode"];
Remove["FeynCalc`repList"];
Remove["FeynCalc`file"];


(*Let us check the configuration of Mathematica and give the user some advices, if necessary*)
If[$FCAdvice,
	If[ $Notebooks &&
		Cases[Options[$FrontEndSession, CommonDefaultFormatTypes], Rule["Output", Pattern[FeynCalc`Private`rulopt, Blank[]]] :> FeynCalc`Private`rulopt, Infinity]=!={TraditionalForm},
		Message[FeynCalc::tfadvice]
	]
]

(* From Mathematica 4.0 onwards there is  "Tr" functions;
	Overload Tr to use TR
*)
Unprotect[Tr];
Tr[Pattern[FeynCalc`Private`trarg,BlankSequence[]]] :=
	TR[FeynCalc`Private`trarg] /; !FreeQ[{FeynCalc`Private`trarg}, FeynCalc`Package`TrFeynCalcObjects];
Tr::usage =
"FeynCalc extension: Tr[list] finds the trace of the matrix or tensor list. Tr[list, f] finds a
generalized trace, combining terms with f instead of Plus. Tr[list, f, n] goes down to level n
in list. \n
Tr[ expression ] calculates the DiracTrace, i.e.,  TR[ expression ], if any of DiracGamma,
DiracSlash, GA, GAD, GAE, GS, GSD or GAE are present in expression.";
Tr/:Options[Tr]:=Options[TR];
Protect[Tr];


If[ !$Notebooks && $FeynCalcStartupMessages,
	$PrePrint = FeynCalcForm;
	WriteString["stdout",
	"$PrePrint is set to FeynCalcForm. Use FI and FC to change the display format.\n"],
	If[ ($Notebooks =!= True),
		$PrePrint = FeynCalcForm
	];
];

(* ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ *)

(* Print FeynCalc's startup message *)
If[ $FeynCalcStartupMessages =!= False,
	Print[	Style["FeynCalc ", "Text", Bold],
			If[ TrueQ[$FeynCalcDevelopmentVersion],
				Style[$FeynCalcVersion <> " (development version). For help, use the ", "Text"],
				Style[$FeynCalcVersion <> " (stable version). For help, use the ", "Text"]
			],
			Style[DisplayForm@ButtonBox["documentation center", BaseStyle->"Link", ButtonData :> "paclet:FeynCalc/",
				ButtonNote -> "paclet:FeynCalc/"], "Text"],
			Style[", check out the ", "Text"],
			Style[DisplayForm@ButtonBox["wiki",ButtonData :> {URL["https://github.com/FeynCalc/feyncalc/wiki"], None},BaseStyle -> "Hyperlink",
				ButtonNote -> "https://github.com/FeynCalc/feyncalc/wiki"],"Text"],
			Style[" or write to the ", "Text"],
			Style[DisplayForm@ButtonBox["mailing list.",ButtonData :> {URL["http://www.feyncalc.org/forum/"], None},BaseStyle -> "Hyperlink",
				ButtonNote -> "http://www.feyncalc.org/forum/"],"Text"]];
	Print[ Style["See also the supplied ","Text"],

	Style[DisplayForm@ButtonBox["examples.", BaseStyle -> "Hyperlink",	ButtonFunction :>
							SystemOpen[FileNameJoin[{$FeynCalcDirectory, "Examples"}]],
							Evaluator -> Automatic, Method -> "Preemptive"], "Text"],
	Style[" If you use FeynCalc in your research, please cite","Text"]];
	Print [Style[" \[Bullet] V. Shtabovenko, R. Mertig and F. Orellana, Comput. Phys. Commun., 207, 432-444, 2016, arXiv:1601.01167","Text"]];
	Print [Style[" \[Bullet] R. Mertig, M. B\[ODoubleDot]hm, and A. Denner, Comput. Phys. Commun., 64, 345-359, 1991.","Text"]]
	];

(* Load PHI... *)
If[	$LoadPhi,
	If[ $FeynCalcStartupMessages,
		PrintTemporary[Style["Loading PHI from " <>  FileNameJoin[{$FeynCalcDirectory, "Phi"}], "Text"]];
	];

	If[Get[FileNameJoin[{$FeynCalcDirectory, "Phi","Phi.m"}]] =!=$Failed,
		If[ $FeynCalcStartupMessages,
			Print[	Style["PHI ", "Text", Bold],
					Style[Phi`$PhiVersion <>", for examples visit ",
						"Text"],
					Style[DisplayForm@ButtonBox["www.feyncalc.org/phi.",	ButtonData :> {URL["http://www.feyncalc.org/phi/"], None},
						BaseStyle -> "Hyperlink", ButtonNote -> "http://www.feyncalc.org/phi/"],"Text"]
			]
		],
		Message[FeynCalc::phierror]
	];
];

(* Load FeynArts... *)
If[	$LoadFeynArts,
	If[ $FeynCalcStartupMessages,
		PrintTemporary[Style["Loading FeynArts from " <>  $FeynArtsDirectory, "Text"]];
	];
	Block[ {FeynCalc`Private`loadfa, FeynCalc`Private`fafiles, FeynCalc`Private`strm, FeynCalc`Private`patch=True, FeynCalc`Private`str},
		If[	$FAPatch,
			(* Check if FeynArts needs to be patched *)
			If[(FeynCalc`Private`fafiles = FileNames["FeynArts.m", $FeynArtsDirectory])=!={},
				FeynCalc`Private`strm = OpenRead[First[FeynCalc`Private`fafiles]];
				If[ Head[FeynCalc`Private`strm] =!= InputStream,
					Message[General::noopen, First[FeynCalc`Private`fafiles]];
					Abort[]
				];
				While[	ToString[FeynCalc`Private`str] != "EndOfFile",
						FeynCalc`Private`str = Read[FeynCalc`Private`strm, String];
						If[ StringMatchQ[ToString[FeynCalc`Private`str], "*patched for use with FeynCalc*", IgnoreCase -> True],
							FeynCalc`Private`patch = False
						]
				];
				Close[First[FeynCalc`Private`fafiles]],
				Message[General::noopen, FileNameJoin[{$FeynArtsDirectory, "FeynArts.m"}]];
				Message[FeynCalc::faerror, $FeynArtsDirectory];
				FeynCalc`Private`patch = False
			];
			(* Apply the patch *)
			If[ FeynCalc`Private`patch,
				FAPatch[]
			]
		];
		FeynCalc`Private`loadfa=Block[ {Print= System`Print},Get[FileNameJoin[{$FeynArtsDirectory, "FeynArts.m"}]]];
		If[FeynCalc`Private`loadfa =!=$Failed,
			(* If everything went fine *)
			If[ $FeynCalcStartupMessages,
				Print[	Style["FeynArts ", "Text", Bold],
						Style[ToString[FeynArts`$FeynArts] <>" patched for use with FeynCalc, for documentation see the ",
							"Text"],
						Style[DisplayForm@ButtonBox["manual", BaseStyle -> "Hyperlink",	ButtonFunction :>
							SystemOpen[First@FileNames[{"*.pdf", "*.PDF"}, FileNameJoin[{$FeynArtsDirectory, "manual"}]]],
							Evaluator -> Automatic, Method -> "Preemptive"], "Text"],
						Style[" or visit ", "Text"],
						Style[DisplayForm@ButtonBox["www.feynarts.de.",	ButtonData :> {URL["http://www.feynarts.de/"], None},
							BaseStyle -> "Hyperlink", ButtonNote -> "www.feynarts.de/"],"Text"]
				];
				Print[ Style["If you use FeynArts in your research, please cite","Text"]];
				Print [Style[" \[Bullet] T. Hahn, Comput. Phys. Commun., 140, 418-431, 2001, arXiv:hep-ph/0012260","Text"]];
			],
			(* If FeynArts didn't load *)
			Message[FeynCalc::faerror, $FeynArtsDirectory];
		];
	];
];

(* 	Some addons might need to add new stuff to the $ContextPath. While inside the
	FeynCalc` path they obviously cannot do this by themselves. However, via
	FeynCalc`Private`AddToTheContextPath they can ask FeynCalc to do this for
	them.
*)
FeynCalc`Private`AddToTheContextPath={};

BeginPackage["FeynCalc`"];
If[ $LoadAddOns=!={},
	FCDeclareHeader/@Map[ToFileName[{$FeynCalcDirectory,  "AddOns",#},#<>".m"] &, $LoadAddOns];
	Get/@Map[ToFileName[{$FeynCalcDirectory,  "AddOns",#},#<>".m"] &, $LoadAddOns]
];
EndPackage[];

If[ FeynCalc`Private`AddToTheContextPath=!={} && ListQ[FeynCalc`Private`AddToTheContextPath],
	$ContextPath = Join[FeynCalc`Private`AddToTheContextPath,$ContextPath]
]

If[ $FCCheckContext,

	Global`globalContextAfterLoadingFC = Names["Global`*"];

	Global`fcContextLowerCase = Select[Names["FeynCalc`*"], LowerCaseQ[StringTake[#, 1]] &];

	Global`whiteListedContextAdditions = {
		"Colour", "CT", "cto", "d", "dD", "eE", "FAChiralityProjector",
		"FADiracMatrix", "FADiracSlash", "FADiracSpinor", "FADiracTrace",
		"FAFourVector", "FAGS", "FAMetricTensor", "FAPolarizationVector",
		"FAScalarProduct", "FASUNF", "FASUNT", "ff", "gA", "gA5", "gA6",
		"gA7", "globalContextAfterLoadingFC", "Gluon", "GraphName",
		"Lorentz", "M", "pp", "TJI111e", "$INTC", "$Special", "$SpecialTLI",
		"fcContextLowerCase", "newObjectsInTheContext",
		"newObjectsInTheGlobalContext", "whiteListedContextAdditions"
	};

	Global`newObjectsInTheGlobalContext = Complement[Global`globalContextAfterLoadingFC, Global`globalContextBeforeLoadingFC]//
		Complement[#,Global`whiteListedContextAdditions]&;



	If[ Global`fcContextLowerCase=!={} || Global`newObjectsInTheGlobalContext=!={},
		Message[FeynCalc::context];
		If[	Global`fcContextLowerCase=!={},
			Print["New lowercase objects in the FeynCalc context: ", Global`fcContextLowerCase]
		];
		If[	Global`newObjectsInTheGlobalContext=!={},
			Print["New lowercase objects in the Global context: ", Global`newObjectsInTheGlobalContext]
		]
	];

	Remove["Global`fcContextLowerCase"];
	Remove["Global`newObjectsInTheGlobalContext"];
	Remove["Global`whiteListedContextAdditions"];
	Remove["Global`globalContextBeforeLoadingFC"];
	Remove["Global`globalContextAfterLoadingFC"];

]





If[	$CloudEvaluation && $FCCloudTraditionalForm,
	$Post = TraditionalForm;
];
