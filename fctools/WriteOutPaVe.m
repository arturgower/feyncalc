(* ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ *)

(* :Title: WriteOutPaVe *)

(* :Author: Rolf Mertig *)

(* ------------------------------------------------------------------------ *)
(* :History: File created on 22 June '97 at 23:01 *)
(* ------------------------------------------------------------------------ *)

(* ------------------------------------------------------------------------ *)

BeginPackage["HighEnergyPhysics`fctools`WriteOutPaVe`",
             "HighEnergyPhysics`FeynCalc`"];

WriteOutPaVe::usage=
"WriteOutPaVe is an option for PaVeReduce and OneLoopSum. 
If set to a string, the
results of all Passarino-Veltman PaVe's are written out.";

(* ------------------------------------------------------------------------ *)

Begin["`Private`"];
   SetAttributes[WriteOutPaVe, ReadProtected];

End[]; EndPackage[];
(* ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ *)
If[$VeryVerbose > 0,WriteString["stdout", "WriteOutPaVe | \n "]];
Null
