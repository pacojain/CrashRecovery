(* ::Package:: *)

(** User Mathematica initialization file **)
$HistoryLength=15;
Do[
	PrependTo[$Path, i],
	{i, FileNames["C:\\Users\\pacoj\\git\\*"]}
];
Do[
	PrependTo[$Path, i],
	{i, FileNames["\\\\wrisync02.wri.wolfram.com\\backup$\\pacoj\\My Documents\\Stash\\*"]}
];
PrependTo[$Path, "C:\\Users\\pacoj\\WolframWorkspaces\\Base\\Alpha\\Source"];
PrependTo[$Path, "C:\\Users\\pacoj\\WolframWorkspaces\\Base\\Alpha\\Tests\\PhysicalSystemDevTests"];
PrependTo[$Path, "C:\\Users\\pacoj\\WolframWorkspaces\\Base\\DataPaclets\\Internal\\DataPacletTools"];
SetOptions[$FrontEnd, 
 FontProperties -> {"ScreenResolution" -> 80}
];
SetOptions[$FrontEndSession, 
  InitializationCellEvaluation -> False, 
  InitializationCellWarning -> False
];
SetOptions[Plot3D, RotationAction->"Clip"];
SetOptions[Graphics3D, RotationAction->"Clip"];
$SwapDirectory= "C:\\Users\\pacoj\\Swap Files\\";

(*DoOnNormalNotebookExit= Put[{Length[Notebooks[]], DateString[]}, $SwapDirectory <> "TimeOfLastNormalExit.txt"];
SetOptions[$FrontEnd,
	FrontEndEventActions->{{"MenuCommand", "Save"}:>
		Put[{AbsoluteCurrentValue[WindowTitle], DateString[]}, $SwapDirectory <> "TimeOfLastNormalExit.txt"],
		PassEventsDown -> True
	}
];
SetOptions[$FrontEnd, 
	NotebookEventActions->{"WindowClose":>
		Put[{AbsoluteCurrentValue[WindowTitle], DateString[]}, $SwapDirectory <> "TimeOfLastNormalExit.txt"],
		PassEventsDown -> True
	}
];*)
SwapDirectoryLookup[nbFileName_String|$Failed]:=Module[
	{nbDir, nbDirOut},
	(* if the file has never been saved *)
	If[ nbFileName===$Failed, Return[$SwapDirectory <> "Recovery\\"] ];
	(* if the notebook is saved to the file system (as something besides "*Untitled*" *)
	If[ ! StringFreeQ[Last[FileNameSplit @ nbFileName],"Untitled"],Return[$SwapDirectory <> "Recovery\\"] ];
	(* else... the typical case *)
	nbDir = Most[Rest[FileNameSplit @ nbFileName]];
	If[Position[nbDir,"pacoj"]!={}, nbDir = nbDir[[((Position[nbDir,"pacoj"][[1,1]])+1);;]] ];
	nbDirOut= FileNameJoin[ FileNameSplit[$SwapDirectory]~Join~nbDir]<>"\\"
];
SaveSwap[nb_NotebookObject]:=Module[
	{swapFileName, swapDir, nbOut},
	swapFileName = ("WindowTitle" /. NotebookInformation[nb]) <> ".swp";
	swapDir = SwapDirectoryLookup[Quiet[NotebookFileName[nb]]];
	If[!DirectoryQ[swapDir], CreateDirectory[swapDir]];
	nbOut = NotebookGet[nb];
	Put[nbOut, swapDir <> swapFileName]
];
RecoverSwap::noswp= "swap file `1` not found in expected location";
RecoverSwap[nbFileName_String]:=Module[
	{swapFileName, swapDir, nbin},
	If[(StringSplit[nbFileName, "."]//Last) === "swp",
		(* then *)
		swapFileName = Last[ FileNameSplit[nbFileName] ];
		swapDir = FileNameJoin[ Most[FileNameSplit[nbFileName]] ],
		(* else *) 
		swapFileName = Last[ FileNameSplit[ nbFileName] ] <> ".swp";
		swapDir = SwapDirectoryLookup[nbFileName];
	];
	If[ FileNames[swapFileName, {swapDir}] == {},
		(* then *)
		Message[RecoverSwap::noswp,swapDir <> swapFileName]; Return[],
		(* else *)
		nbin= Get[FileNameJoin[{swapDir, swapFileName}]]; NotebookPut[nbin]
	]
];
(*SaveSwap2[nb_NotebookObject]:=Module[
	{fileName, swapFileName, nbout},
	fileName= Last[ FileNameSplit[NotebookFileName[nb]] ];
	swapFileName= "." <> fileName <> ".swp";
	nbout= NotebookPut[NotebookGet[nb]];
	NotebookSave[nbout,NotebookDirectory[nb] <> swapFileName];
	NotebookClose[nbout]
];*)
AutoSaveSwaps= CreateScheduledTask[
	SaveSwap /@ Select[Notebooks[], "ModifiedInMemory" /. NotebookInformation[#]&],
	300
]
StartScheduledTask[AutoSaveSwaps]



