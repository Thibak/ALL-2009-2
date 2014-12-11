/***********************************************************************************************************/
/***********************************************************************************************************/
/***********************************************************************************************************/
/***********************************************************************************************************/
/*****************                                                                       *******************/
/****************                      Отчет по протоколу ОЛЛ-2009                        ******************/
/*****************                          Только по Т-ОЛЛ                              *******************/
/***********************************************************************************************************/
/***********************************************************************************************************/
/***********************************************************************************************************/
/***********************************************************************************************************/
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
%let cens = (20);
*20, 27, 99, 132, 258, 264;

%macro Eventan(dat,T,C,i,s,cl,f,for, ttl);
/*
dat -имя набора данных,
T - время,
C - индекс события/цензурирования,
i=0, если с индекс события,
i=1, если с индекс цензурирования.
s = пусто,если строится кривая выживаемости
s = F, если строится кривая накопленной вероятности
cl = cl,если показывать доверительный интервал
cl = пусто,если не показывать доверительный интервал
s = F, если строится кривая накопленной вероятности
f = фактор (страта) ЕСЛИ ПУСТО ТО БЕЗ СТРАТЫ
for = формат (1.0 для целочисленных значаний, когда нет специального формата)
ttl = заголовок
*/

data _null_; set &dat;
   length tit1 $256 tit2 $256;
*чтение лейболов;
tit1=vlabel(&T);
%if &f ne %then %do; tit2=vlabel(&f);%end;
   * положили лейбала в макропеременную;
   call symput('tt1',tit1);
   call symput('tt2',tit2);
output;
   stop;
   keep tit1 tit2;
run;
title1 &ttl;
title2 " зависимая:  &tt1 // фактор       :  &tt2";
ods graphics on;
ods exclude WilHomCov LogHomCov HomStats  Quartiles ; *ProductLimitEstimates;
proc lifetest data=&dat plots =(s( &s &cl))  method=pl ;
    %if &f ne %then %do; strata &f/test=logrank;
    id &f;format   &f &for;%end;
    time &T*&C(&i) ;
run;
ods graphics off;
%mend;


/*------------------------------------------------------------------------------------------*/






proc means data = &LN..all_pt N;
	var pguid;
   title 'Всего записей';
run;

proc freq data=&LN..new_pt ; *информация о количестве;
   tables oll_class / nocum;
/*NOPERCENT;*/
   title 'Иммунофенотип';
   FORMAT oll_class oc_f.;
run;

title1 "T-Oll";

proc means data = &LN..toll n median max min ;
   var age;
   title 'Возраст больных (медиана, разброс)';
run;

/*proc freq data=&LN..toll ;*/
/*   tables age / nocum;*/
/*   title 'Возраст, группы';*/
/*   format age age_group_f.;*/
/*run;*/

proc freq data=&LN..toll ;
   tables new_gendercodename / nocum;
   title 'Пол';
run;

proc sort data = &LN..toll;
	by T_class12;
run;

proc freq data=&LN..toll ; *информация о количестве;
   tables T_class12 / nocum;
/*NOPERCENT;*/
   title 'Иммунофенотип (детально)';
   FORMAT T_class12 T_class12_f.;
run;

proc means data=&LN..toll n median max min ;
	var age new_hb	new_l	new_tp	blast_km	new_blast_pk	new_creatinine	new_ldh	new_albumin	new_protromb_ind	new_dlin_rs	new_poperech_rs;
	title "Общие лабораторные показатели для ХТ";
run;

proc means data=&LN..toll n median max min ;
	by T_class12;
	var age new_hb	new_l	new_tp	blast_km	new_blast_pk	new_creatinine	new_ldh	new_albumin	new_protromb_ind	new_dlin_rs	new_poperech_rs;
	title "Общие лабораторные показатели для ХТ (по имунофенотипам)";
	FORMAT T_class12 T_class12_f.;
run;

proc freq data=&LN..toll ; *информация о количестве;
   tables T_class12*new_citogenname / nocum;
/*NOPERCENT;*/
   title 'Выполнена цитогенеттика';
   FORMAT T_class12 T_class12_f.;
run;



proc freq data = &LN..cito;
	tables T_class12*new_normkariotipname/nocum;
   title 'Нормальный кариотип (из измеренных)';
   FORMAT T_class12 T_class12_f.;
run;

proc freq data = &LN..cito;
	tables T_class12*new_mitozname/nocum;
   title 'Нет митозов (из измеренных)';
   FORMAT T_class12 T_class12_f.;
run;


proc freq data=&LN..toll ; *информация о количестве;
   tables T_class12*new_neyrolekname / nocum;
/*NOPERCENT;*/
   title 'Поражение ЦНС';
   FORMAT T_class12 T_class12_f.;
run;

proc freq data=&LN..toll ; *информация о количестве;
   tables T_class12*new_uvsredostenname / nocum;
/*NOPERCENT;*/
   title 'Увеличение средостения';
   FORMAT T_class12 T_class12_f.;
run;

proc freq data=&LN..toll ;
   tables T_class12*FRint/ nocum;
   title 'Достижение ремиссии (по фазам)';
   format FRint FRint_f. T_class12 T_class12_f.;
run;

proc freq data=&LN..toll ;
   tables T_class12*i_ind_death/ nocum;
   title 'Смерть на индукции';
   format i_ind_death y_n. T_class12 T_class12_f.;
run;

proc freq data=&LN..toll ;
   tables T_class12*i_res/ nocum;
   title 'Случаев резистентности';
   format i_res y_n. T_class12 T_class12_f.;
run;

proc freq data=&LN..toll ;
   tables T_class12*TR/ nocum;
   title 'Результат лечения';
   format TR TR_f. T_class12 T_class12_f.;
run;



proc freq data=&LN..toll;
   tables T_class12*tkm_au_al/ nocum;
   title 'ауто/алло-ТКМ';
   format tkm_au_al tkm_au_al_f. T_class12 T_class12_f.;
run;

data tmp;
	set &LN..toll;
	if tkm_au_al in (1,2) and i_death = 1;
run;

proc print data = tmp;
	title 'ТКМ + смерть (проверить последовательность событий)';
	var pt_id name tkm_au_al i_death date_TKM date_death;
	 format date_TKM DDMMYY10. date_death DDMMYY10. tkm_au_al tkm_au_al_f.;
run; 

data tmp;
	set &LN..toll;
	if date_death - pr_b < 10 and date_death ne .;
run;

proc print data = tmp;
	title 'Смерть менее чем через 10 дней после начала лечения';
	var pt_id name pr_b date_death new_group_riskname new_oll_classname ;
	 format pr_b DDMMYY10. date_death DDMMYY10. tkm_au_al tkm_au_al_f.;
run; 
%eventan (&LN..toll, TLive, i_death, 0,,&y,,,"Выживаемость");
%eventan (&LN..toll, TRF, iRF, 0,,&y,,,"Безрецидивная выживаемость");

%eventan (&LN..toll, TLive, i_death, 0,,&y,T_class12,T_class12_f.,"Выживаемость");
%eventan (&LN..toll, TRF, iRF, 0,,&y,T_class12,T_class12_f.,"Безрецидивная выживаемость");

%eventan (&LN..toll_LM, TLive_LM, i_death, 0,,&y,tkm_au_al, tkm_au_al_f.,"Ландмарк анализ. Общая выживаемость");
%eventan (&LN..toll_LM, TRF_LM, iRF, 0,,&y, tkm_au_al, tkm_au_al_f.,"Ландмарк анализ. Безрецидивная выживаемость");
%eventan (&LN..toll_LM, Trel_LM, i_rel, 0,F,&y,tkm_au_al, tkm_au_al_f.,"Ландмарк анализ. Вероятность развития рецидива");



/*proc means data = &LN..new_pt median max min ;*/
/*   var TD;*/
/*   title 'Среднее время наблюдения';*/
/*run;*/
/**/
/*proc sort data = &LN..new_pt;*/
/*	by tkm_au_al;*/
/*run;*/
/**/
/*proc means data = &LN..new_pt median max min ;*/
/*	by tkm_au_al;*/
/*   var TD;*/
/*   title 'Среднее время наблюдения по группам';*/
/*run;*/



/*proc sort data=&LN..all_pt;*/
/*	by new_oll_class;*/
/*run;*/
/**/
/*proc means data = &LN..new_pt median max min ;*/
/*   var Ttkm;*/
/*   title 'Среднее кол. мес. до ТКМ (медиана, разброс)';*/
/*run;*/
/*proc freq data=&LN..all_pt ORDER = DATA;*/
/*   tables new_oll_classname / nocum;*/
/*   title 'Иммунофенотип (детально)';*/
/*run;*/
