(* ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ *)

(* :Title: Tf *)

(* :Author: Rolf Mertig *)

(* ------------------------------------------------------------------------ *)
(* :History: File created on 22 June '97 at 23:01 *)
(* ------------------------------------------------------------------------ *)

(* :Summary: Tf *) 

(* ------------------------------------------------------------------------ *)

BeginPackage["HighEnergyPhysics`qcd`Tf`",
             "HighEnergyPhysics`FeynCalc`"];

Tf::usage = 
"Tf is 1/2 for SU(N).";

(* ------------------------------------------------------------------------ *)

Begin["`Private`"];
   SetAttributes[Tf, ReadProtected];

   Tf /:
   MakeBoxes[Tf  ,TraditionalForm] := SubscriptBox["T","f"];


End[]; EndPackage[];
(* ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ *)
If[$VeryVerbose > 0,WriteString["stdout", "Tf | \n "]];
Null
