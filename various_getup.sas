/*идентификатор компа*/ *D - sony, Z - ГНЦ;
*Без предефайна оказывается не работает;
%let disk = .;
%let lastname= .;
%macro what_OC;
%if &sysscpl = W32_7PRO %then 
	%do;
		%let disk = D; *sony;
	%end;
%if &sysscpl = X64_7PRO %then 
	%do;
		%let disk = Z; *работа;
	%end;
%mend;


/*определитель ОС*/
/*data comp;*/
/*	OC = "&sysscpl";*/
/*run;*/
/**/
/*proc print data = COMP;*/
/*run;*/
%what_OC;

%let LN = ALL2009; * имя библиотеки;
Libname &LN "&disk.:\AC\OLL-2009\SAS"; * Библиотека данных;
%let y = cl;


/*proc sort data = &LN..toll;*/
/*	by i_rel descending TRF;*/
/*run;*/
/**/
/*proc print data = &LN..toll;*/
/*	var pt_id name i_rel TRF;*/
/*run;*/



proc sort data=&LN..toll_LM_xa;
	by tkm_au_al;
run;

proc means data = &LN..toll_LM_xa n median max min ;
	by tkm_au_al;
	var age;
   title 'Возраст больных (медиана, разброс)';
   	format tkm_au_al tkm_au_al_f.;
run;

/*proc freq data=&LN..toll ;*/
/*   tables age / nocum;*/
/*   title 'Возраст, группы';*/
/*   format age age_group_f.;*/
/*run;*/

proc freq data=&LN..toll_LM_xa ;
   tables tkm_au_al*new_gendercodename / nocum;
   title 'Пол';
   format tkm_au_al tkm_au_al_f.;
run;



proc freq data=&LN..toll_LM_xa  ; *информация о количестве;
   tables tkm_au_al*T_class12 / nocum;
/*NOPERCENT;*/
   title 'Иммунофенотип (детально)';
   FORMAT T_class12 T_class12_f. tkm_au_al tkm_au_al_f.;
run;

proc means data=&LN..toll_LM_xa  n median max min ;
	by tkm_au_al;
	var age new_hb	new_l	new_tp	blast_km	new_blast_pk	new_creatinine	new_ldh	new_albumin	new_protromb_ind	new_dlin_rs	new_poperech_rs;
	title "Общие лабораторные показатели для ХТ";
	format tkm_au_al tkm_au_al_f.;
run;


proc freq data=&LN..toll_LM_xa  ; *информация о количестве;
   tables tkm_au_al*new_citogenname / nocum;
/*NOPERCENT;*/
   title 'Выполнена цитогенеттика';
   FORMAT  tkm_au_al tkm_au_al_f.;
run;



proc freq data=&LN..toll_LM_xa  ; *информация о количестве;
   tables tkm_au_al*new_neyrolekname / nocum;
/*NOPERCENT;*/
   title 'Поражение ЦНС';
   FORMAT  tkm_au_al tkm_au_al_f.;
run;

proc freq data=&LN..toll_LM_xa  ; *информация о количестве;
   tables tkm_au_al*new_uvsredostenname / nocum;
/*NOPERCENT;*/
   title 'Увеличение средостения';
   FORMAT tkm_au_al tkm_au_al_f.;
run;

proc freq data=&LN..toll_LM_xa  ;
   tables tkm_au_al*FRint/ nocum;
   title 'Достижение ремиссии (по фазам)';
   format FRint FRint_f. tkm_au_al tkm_au_al_f.;
run;

proc freq data=&LN..toll_LM_xa  ;
   tables tkm_au_al*i_ind_death/ nocum;
   title 'Смерть на индукции';
   format i_ind_death y_n.  tkm_au_al tkm_au_al_f.;
run;


proc freq data=&LN..toll_LM_xa  ;
   tables tkm_au_al*TR/ nocum;
   title 'Результат лечения';
   format TR TR_f. tkm_au_al tkm_au_al_f.;
run;

proc freq data=&LN..toll_LM_xa  ;
   tables tkm_au_al*new_group_riskname/ nocum;
   title 'Группа риска';
   format   tkm_au_al tkm_au_al_f.;
run;


proc freq data=&LN..toll_LM_xa  ;
   tables tkm_au_al*reg/ nocum;
   title 'Регион';
   format   tkm_au_al tkm_au_al_f. reg reg_f.;
run;

%eventan (&LN..toll_LM_xa, TLive_LM, i_death, 0,,&y,tkm_au_al, tkm_au_al_f.,"Ландмарк анализ. Общая выживаемость");
%eventan (&LN..toll_LM_xa, TRF_LM, iRF, 0,,&y, tkm_au_al, tkm_au_al_f.,"Ландмарк анализ. Безрецидивная выживаемость");
%eventan (&LN..toll_LM_xa, Trel_LM, i_rel, 0,F,&y,tkm_au_al, tkm_au_al_f.,"Ландмарк анализ. Вероятность развития рецидива");


data ALL2009.NCH_lm_xa;
	SET ALL2009.toll_lm_xa;
	if reg = 1;
run;

proc freq data=all2009.toll_lm_xa;
	tables reg*tkm_au_al/nocum;
	format tkm_au_al tkm_au_al_f. reg reg_f.;
run;

%eventan (ALL2009.NCH_lm_xa, TLive_LM, i_death, 0,,&y,tkm_au_al, tkm_au_al_f.,"ГНЦ. Ландмарк анализ. Общая выживаемость");
%eventan (ALL2009.NCH_lm_xa, TRF_LM, iRF, 0,,&y, tkm_au_al, tkm_au_al_f.,"ГНЦ. Ландмарк анализ. Безрецидивная выживаемость");
%eventan (ALL2009.NCH_lm_xa, Trel_LM, i_rel, 0,F,&y,tkm_au_al, tkm_au_al_f.,"ГНЦ. Ландмарк анализ. Вероятность развития рецидива");


data ALL2009.reg_lm_xa;
	SET ALL2009.toll_lm_xa;
	if reg = 0;
run;


%eventan (ALL2009.reg_lm_xa, TLive_LM, i_death, 0,,&y,tkm_au_al, tkm_au_al_f.,"Регионы. Ландмарк анализ. Общая выживаемость");
%eventan (ALL2009.reg_lm_xa, TRF_LM, iRF, 0,,&y, tkm_au_al, tkm_au_al_f.,"Регионы. Ландмарк анализ. Безрецидивная выживаемость");
%eventan (ALL2009.reg_lm_xa, Trel_LM, i_rel, 0,F,&y,tkm_au_al, tkm_au_al_f.,"Регионы. Ландмарк анализ. Вероятность развития рецидива");


%eventan (&LN..toll, TLive, i_death, 0,,&y,age, age_group_30_f.,"Выживаемость");
%eventan (&LN..toll, TRF, iRF, 0,,&y,age, age_group_30_f.,"Безрецидивная выживаемость");


%eventan (&LN..toll_LM_xa, TLive_LM, i_death, 0,,&y,age, age_group_30_f.,"Ландмарк анализ. Общая выживаемость");
%eventan (&LN..toll_LM_xa, TRF_LM, iRF, 0,,&y, age, age_group_30_f.,"Ландмарк анализ. Безрецидивная выживаемость");
%eventan (&LN..toll_LM_xa, Trel_LM, i_rel, 0,F,&y,age, age_group_30_f.,"Ландмарк анализ. Вероятность развития рецидива");



%eventan (&LN..toll, TLive, i_death, 0,,&y,reg, reg_f.,"Общая выживаемость");
%eventan (&LN..toll, TRF, iRF, 0,,&y, reg, reg_f.,"Безрецидивная выживаемость");
%eventan (&LN..toll, Trel, i_rel, 0,F,&y,reg, reg_f.,"Вероятность развития рецидива");

%eventan (&LN..toll, TLive, i_death, 0,,&y,new_group_riskname,,"Общая выживаемость");
%eventan (&LN..toll, TRF, iRF, 0,,&y, new_group_riskname,,"Безрецидивная выживаемость");
%eventan (&LN..toll, Trel, i_rel, 0,F,&y,new_group_riskname,,"Вероятность развития рецидива");

data tmp;
	set &LN..toll;
	if new_group_risk in (1,2);
run;

%eventan (tmp, TLive, i_death, 0,,&y,new_group_riskname,,"Общая выживаемость");
%eventan (tmp, TRF, iRF, 0,,&y, new_group_riskname,,"Безрецидивная выживаемость");
%eventan (tmp, Trel, i_rel, 0,F,&y,new_group_riskname,,"Вероятность развития рецидива");


proc freq data=&LN..toll;
   tables T_class12*new_splenomegname/ nocum;
   title 'Акроспленомегалия';
   format T_class12 T_class12_f.;
run;

proc freq data=&LN..toll;
   tables T_class12*new_group_riskname/ nocum;
   title 'Распределение по группам риска';
   format T_class12 T_class12_f.;
run;


proc freq data=&LN..toll;
   tables new_blast_km/ nocum;
   title 'бластных клеток в КМ';
   format new_blast_km blast_km_f.;
run;