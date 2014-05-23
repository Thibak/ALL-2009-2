
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
Eventan(dat,T,C,i,s,cl,f,for, ttl)
dat - имя набора данных,
T   - время,
C   - индекс события/цензурирования,
i   - идетификатор цензурирования
	i = 0, если с индекс события,
	i = 1, если с индекс цензурирования.
s   - пусто,если строится кривая выживаемости
	s = F, если строится кривая накопленной вероятности
cl  - пусто,если не показывать доверительный интервал
	cl = cl, если показывать доверительный интервал
f   - фактор (страта) ЕСЛИ ПУСТО ТО БЕЗ СТРАТЫ
for - формат (1.0 для целочисленных значаний, когда нет специального формата)
ttl - заголовок
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


proc format;
    value oc_f  1 = "B-клеточный" 2 = "T-клеточный" 3 = "Бифенотипический" 0 = "Неизвестен" ;
    value gender_f 1 = "Мужчины" 2 = "Женщины";
    value risk_f 1 = "Стандартная" 2 = "Высокая" 3 = "нет данных";
    value age_group_28_f low-28 = "до 28-ми лет" 28-high = "после 28-ми лет";
    value age_group_30_f low-30 = "до 30-ти лет" 30-high = "после 30-ти лет";
    value age_group_33_f low-33 = "до 33-х лет" 33-high = "после 33-х лет";
	value age_group_f low-29 = "AYA" 29-high = "Adult";
	value tkm_f 0="нет" 1="ауто" 2="алло";
	value it_f 1="есть" 0 = "нет";
	value time_error_f . = "нет ошибок" 
		0 = "дата последнего визита не заполнена" 
		1 = "дата последнего события (этапа) больше чем дата последнего контакта" 
		2 = "дата ремиссии больше даты последнего контакта" 
		3 = "дата рецедива больше даты последнего контакта"
		4 = "date bmt > lastdate";

/*	  if date_rem > lastdate then do; time_error = 2; lastdate = date_rem; end;*/
/*    if date_rel > lastdate then do; time_error = 3; lastdate = date_rel; end;*/
	value new_group_risk_f 1 = "стандартная" 2 = "высокая";
	value y_n 0 = "нет" 1 = "да";
	value yn_e 0 = "no" 1 = "yes";
	value au_al_f 1 = "ауто" 2 = "алло - родственная" ;
	value reg_f 0 = "Регионы" 1 = "ГНЦ"; 
	value T_class12_f 0 = "T1+T2" 1 = "T3" 2 = "T4";
	value T_class124_f 0 = "T1+T2+T4" 1 = "T3";
	value TR_f 0 = "Полная ремиссия" 1 = "Резистентная форма" 2 = "Смерть в индукции";
	value BMinv_f 0 = "Без поражения" 1 = "С поражением";
	value AAC_f 0 = "Химиотерапия" 1 = "Ауто ТКМ" 2 = "Алло ТКМ" 3 = "Ранний рецидив" 4 = "Смерть в ремиссии" 5 = "на индукции (T < 5 мес)";
	value FRint_f 0 = "ПР на другой фазе" 1 = "ПР на 1-ой фазе индукции" 2 = "ПР на 2-ой фазе индукции";
	value BMT_f 0 = "Химиотерапия" 1 = "ТКМ";
	value tkm_au_al_f 0 = "Химиотерапия" 1="Ауто-ТКМ" 2="Алло-ТКМ";
run;

/*------------ препроцессинг восстановления реляций и целостности данных ---------------*/
data &LN..all_pt;
    set &LN..all_pt;
    rename
        new_protokol_ollid = pguid
		new_nbrpacient = pt_id
        new_name = name
        new_datest = pr_b
        new_datefn = pr_e
        new_lastvisitdate = lastdate
		new_blast_km = blast_km
        ;
	label 
		new_group_risk = "группа риска"
		new_normkariotip = "Normal karyotype"
		;
		run;
data &LN..all_et;
    set &LN..all_et;
    rename
        new_datest = ph_b
        new_datefn = ph_e
        new_protokolname = name_e
        new_protokol = pguid
		new_group_risk = fin_group_risk
		new_group_riskname = fin_group_riskname
		ownerid = ownerid_et
		owneridname = owneridname_et	
		createdby = createdby_et
		createdbyname	= createdbyname_et
		createdon	= createdon_et
		Modifiedby	= Modifiedby_et
		Modifiedbyname	= Modifiedbyname_et
		Modifiedon = Modifiedon_et
        ;
		run;
data &LN..all_ev;
    set &LN..all_ev;
    rename
        new_protokol_oll = pguid
        new_protokol_ollname = name
		ownerid = ownerid_ev
		owneridname = owneridname_ev	
		createdby = createdby_ev
		createdbyname	= createdbyname_ev
		createdon	= createdon_ev
		Modifiedby	= Modifiedby_ev
		Modifiedbyname	= Modifiedbyname_ev
		Modifiedon = Modifiedon_ev
    ;
	run;
/*------ цензурирование, и вычисление производных показателей ----------*/


data cens;
	set &LN..all_pt;
	if pt_id in &cens then output;
run;

proc print data = cens split='*' N;
	var pt_id name;
	label pt_id = 'Номер пациента*в протоколе'
          name = 'Имя*в базе пациентов';
	title "Из базы принудительно исключены следующие записи" ;
run;

data null;
	set &LN..all_pt;
	if pt_id = . then output;
run;

proc print data = null split='*' N;
	var pt_id name;
	label pt_id = 'Номер пациента*в протоколе'
          name = 'Имя*в базе пациентов';
	title "В базе не имеют номера в протоколе" ;
run;

proc sort data=&LN..all_pt;
	by pt_id;
run;


/*----- очередная заплатка возраста. По данным ЕН обнавляем возраста, там где нет данных заклеиваем данными из базы*/
/*-- подцепляем правки из &LN..rps --*/
proc sort data=&LN..tmp_age;
	by pt_id;
run;


proc sort data=&LN..rps;
	by pt_id;
run;

data &LN..all_pt; 
	merge &LN..all_pt &LN..tmp_age &LN..rps;
	by pt_id;
run;


data &LN..all_pt; *только по таблице пациентов;
    set &LN..all_pt;

	if new_group_risk = 3 then new_group_risk = .; * 3 -- код для "нет данных", что равноценно отсутствию данных!;



if age = . then age = floor(yrdif(new_birthdate, pr_b,'AGE'));  *если возраста нет в базе ЕН, то предположительно в базе АС дата рождения забита правильно;
    *FORMAT age 2.0;

/*-------------------*/

    /* тип лейкоза */
    select;
        when (new_oll_class in (1,2,3) )   oll_class = 1; /*B-OLL*/
        when (new_oll_class in (5,6,7,8) ) oll_class = 2; /*T-OLL*/
        when (new_oll_class = 99)  oll_class = 0; /*неизвестен*/
        when (new_oll_class = 9 )  oll_class = 3; /*бифенотипически*/
        otherwise;
    end;

/*подправляем данные*/


/* ручное цензурирование данных*/
    if NOT (pt_id in &cens ) then output;
run;


footnote " ";




/*-----------------------------------блок парсинга событий на этапах----------------------*/
proc sort data=&LN..all_et;
    by pguid new_etap_protokol; *сортируем таблицу этапов по ID пациентов и по этапам протокола (в хронологическом порядке);
run;

proc sort data=&LN..all_pt;
    by pguid; *сортируем таблицу этапов по ID пациентов и по этапам протокола (в хронологическом порядке);
run;

/*Соединяем таблицы пациентов и этапов, определяем для кого из пациентов нет записи об этапах*/
data &LN..new_et;
    merge &LN..all_pt (in = i1) &LN..all_et (in = i2);
    by pguid;

    it1 = i1;
    it2 = i2;
run;

*убираем цензурированные записи;
data &LN..new_et;
	set &LN..new_et;
	if it1 ne 0;
run;



/*прочесываем созданную таблицу, для каждой последней записи загоняем смену на дексаметазон, и номер этапа. Последнюю выводим в датасет*/
data &LN..new_pt /*(keep=)*/;
    set &LN..new_et;
    by pguid;
    retain ec d_ch time_error ind1bg ind1end ind2bg ind2end; *ec -- это количество этапов "свернутых";
    if first.pguid then 
		do;  
			ec = 0; 
			d_ch = .;  
			time_error = .; 
			ind1bg = .; 
			ind1end = .; 
			ind2bg = .; 
			ind2end = .; 
		end;
/*--------------------------------------------------*/
    if it2 then ec + 1;
	if lastdate = . then time_error = 0;

    if ph_b > lastdate and time_error = 0 then do; lastdate = ph_b; end; *Проверка на последнюю дату. ;
    if ph_b > lastdate then do; lastdate = ph_b; time_error = 1; end;
    if ph_e > lastdate and time_error = 0 then do; lastdate = ph_e; end;
	if ph_e > lastdate then do; lastdate = ph_e; time_error = 1; end;

	if new_etap_protokol = 1 then do; 	
		if new_smena_na_deksamet = 1 then d_ch = 1;
		if new_smena_na_deksamet = 0 then d_ch = 0;
		end;
	if new_etap_protokol = 2 then do; ind1bg = ph_b; ind1end = ph_e; end;
	if new_etap_protokol = 3 then do; ind2bg = ph_b; ind2end = ph_e; end;


/*---------------------------------------------------*/
    if last.pguid then
        do;
			*if time_error ne . then output &LN..error_timeline;

            output &LN..new_pt;
            d_ch = .;
			time_error = .;
			ind1bg = .; 
			ind1end = .; 
			ind2bg = .; 
			ind2end = .; 
        end;
	label d_ch = "Смена на дексаметазон";
run;

data &LN..new_pt;
	set &LN..new_pt;
			if (ind1bg  = .) then ind1bg  = pr_b + 7; 
			if (ind1end = .) then ind1end = ind1bg + 36;
			if (ind2bg  = .) then ind2bg  = ind1end;
			if (ind2end = .) then ind2end = ind1bg + 70;
run;


/*РЕПОРТИНГ ОБ ОШИБКАХ РЕЛЯЦИЯХ ПАЦИЕНТ-ЭТАП*/

proc sort data = &LN..error_ptVSet;
	by pt_id;
run;

data &LN..error_ptVSet;
	set &LN..new_et (keep = pt_id name name_e new_etap_protokolname it1 it2);
	if it1 ne it2 then output; 
run;

proc print data = &LN..error_ptVSet split='*' N obs="Номер*ошибки";
	var pt_id name name_e new_etap_protokolname it1 it2;
	label pt_id = 'Номер пациента*в протоколе'
          name = 'Имя*в базе пациентов'
          name_e = 'Имя*в базе этапов'
		  new_etap_protokolname = 'этап'
		  it1 = 'Запись*в базе пациентов' 
		  it2 = 'Запись* в базе этапов';
	title "Ошибки в базе (пара пациент - этап)" ;
	format  it1 it2 it_f. ; 
run;

/*----------------------------------------------------------------------------------------*/





/*-------------------------- подготовка переменных для событийного анализа ----------------------------*/

/*прошерстить таблицу событий и убрать все повторяющиеся, оставив только первые*/
proc sort data=&LN..all_ev;
    by pguid new_event new_event_date ;
run;



data &LN..all_ev_red;
	set &LN..all_ev;
	by pguid new_event new_event_date ;
	if first.new_event then output;
run;


/*Прицепляем события к пациентам. Нам нужны индикаторы и даты рецедива и смерти*/

proc sort data=&LN..all_ev_red;
    by pguid;
run;

proc sort data=&LN..new_pt;
    by pguid;
run;

data &LN..new_ev;
    merge &LN..new_pt (in = i1) &LN..all_ev_red(in = i2) ;
    by pguid;

    ie1 = i1;
    ie2 = i2;
run;

proc sort data=&LN..new_ev;
    by pguid;
run;

/*  rem ремиссия = 1 */
/*  res резистентность = 2*/
/*  death Смерть = 3*/
/*  tkm ТКМ = 4*/
/*  rel рецедив = 5*/


/*--- генерируем индикаторы рецидива/ремиссии/смерти ---*/
data &LN..new_pt;
    set &LN..new_ev;
    by pguid;
    retain i_rem date_rem FRint /**/ i_death date_death i_ind_death /**/i_tkm date_tkm tkm_au_al/**/ i_rel date_rel /**/ i_res date_res /**/ Laspot;
    if first.pguid then 
		do; 
			i_rem = 0; date_rem = .; FRint = .; 
			i_res = 0; date_res = .; 
			i_death = 0; date_death = .; i_ind_death = 0; 
			i_tkm = 0; date_tkm = .; tkm_au_al = 0;
			i_rel = 0; date_rel = .;
			Laspot = 0; 
		end;
/*----------------------------------*/
    if new_event = 1 then 
		do; 
			i_rem = 1; 
			date_rem = new_event_date; 

			*если нет даты начала терапии, предполагаем, что все идет по регламенту;


			select;
				when (ind1bg-10 <= date_rem <= ind1end+15) FRint = 1; *склеиваем этапы;
				*when (ind1bg-2 <= date_rem <= ind2bg +2 /*ind1end*/) FRint = 1; *склеиваем этапы;
				when (ind2bg+15   <= date_rem <= ind2end+2) FRint = 2;  
				otherwise FRint = 0;
			end;
		end;
	if new_event = 2 then do; i_res = 1; date_res = new_event_date; end;
    if new_event = 3 then do; i_death = 1; date_death = new_event_date; end;
	 if new_event_txt = "В индукции" then i_ind_death = 1; 
	if new_event = 4 then do; i_tkm = 1; date_tkm = new_event_date; end;
	 if new_event_txt = "ауто" then tkm_au_al = 1; 
	 if new_event_txt in ("алло - родственная","алло - неродственная")  then tkm_au_al = 2;
    if new_event = 5 then do; i_rel = 1; date_rel = new_event_date; end;
	if new_aspor_otmena = 1 then laspot = 1;
/*---------------------------------*/
    if last.pguid then 
		do; 
			if ie1 ne 0 then  output; *<-----------------------;
			i_rem = 0; date_rem = .; FRint = .;
			i_res = 0; date_res = .; 
			i_death = 0; date_death = .; i_ind_death = 0; 
			i_tkm = 0; date_tkm = .; tkm_au_al = 0;
			i_rel = 0; date_rel = .;
			Laspot = 0; 
		end;
run;

*убираем цензурированные записи;
data &LN..new_pt;
	set &LN..new_pt;
	if ie1 ne 0;
run;
	

/*поставить заплатку если время рецидива равно нулю то сегодняшняя дата <----------- ЕСТЬ ЛИ ЭТО????*/
/*обновление последнего контакта за счет смерти*/  
Data &LN..new_pt;
    set &LN..new_pt;
	if time_error = . then 
		do;
    	if date_rem > lastdate then time_error = 2;
    	if date_rel > lastdate then time_error = 3;
		if date_tkm > lastdate then time_error = 4;
		end;

    if date_rem > lastdate then lastdate = date_rem; 
    if date_rel > lastdate then lastdate = date_rel;
	if date_tkm > lastdate then lastdate = date_tkm;
	if date_death ne .     then lastdate = date_death; 

	if i_death = 1 and time_error = 0 then time_error = .;

run;

/*!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!*/

data &LN..error_timeline;
	set &LN..new_pt;
	if time_error ne . then output;
run;

/*Выживаемость*/
/*переводим в месяцы*/
Data &LN..new_pt;
    set &LN..new_pt;

    select (i_death);
        when (1) TLive = (date_death - pr_b)/30;
        when (0) TLive = (lastdate   - pr_b)/30;
        otherwise;
    end;

    select (i_rem);
        when (1) Trem = (date_rem - pr_b)/30;
        when (0) Trem = (lastdate - pr_b)/30;
        otherwise;
    end;

    select (i_rel);
        when (1) Trel = (date_rel - date_rem)/30;
        when (0) Trel = (lastdate - date_rem)/30;
        otherwise;
    end;

	if (i_tkm) then Ttkm = (date_tkm - date_rem)/30;
run;

/*Безрецедивная выживаемость*/
Data &LN..new_pt;
    set &LN..new_pt;
    iRF = i_rel | i_death;
    Select;
        when (i_rel)  TRF = Trel;
        when (i_death) TRF = (date_death - date_rem)/30;
        when (iRF = 0) TRF = (lastdate - date_rem)/30;
        otherwise;
    end;

run;

*определяем новые группы;

Data &LN..new_pt;
    set &LN..new_pt;
    select (new_oll_class);
        when (5) do; T_class12 = 0 ; T_class124 = 0 ; end;  *T1;
		when (6) do; T_class12 = 0 ; T_class124 = 0 ; end; *T2;
		when (7) do; T_class12 = 1 ; T_class124 = 1; end; *T3;
		when (8) do; T_class12 = 2 ; T_class124 = 0; end; *T4;
        otherwise;
    end;
	
*проставляем новые ппороговые показатели;

	*бластные клетки;
	Select; 
		when (blast_km => 5) BMinv = 1; 
		when (blast_km = .) BMinv = .;
		when (blast_km  < 5) BMinv = 0;
		otherwise;
	end; 

	*лейкоциты;
    select (oll_class);
		when (2) do; *T-oll;
			select;
				when (new_l<100) l_b = 0;
				when (new_l>100) l_b = 1;
				when (new_l = .) l_b = .;
				otherwise l_b=.;
			end; end;
		when (1) do; *B-oll;
			select;
				when (new_l<30) l_b = 0;
				when (new_l>30) l_b = 1;
				when (new_l = .) l_b = .;
				otherwise a=.;
			end; end;
		otherwise l_b =.;
	end;

	*креатинин;
		select;
			when (new_creatinine < 120) creatinine_b = 0;
			when (new_creatinine > 120) creatinine_b = 1;
			when (new_creatinine = .)   creatinine_b=.;
			otherwise creatinine_b=.;
		end; 

	*Билирубин;
		select;
			when (new_bilirubin < 30) bilirubin_b = 0;
			when (new_bilirubin > 30) bilirubin_b = 1;
			when (new_bilirubin = .)  bilirubin_b=.;
			otherwise bilirubin_b=.;
		end; 

	*Альбумин;
		select;
			when (new_albumin > 35) albumin_b = 0;
			when (new_albumin < 35) albumin_b = 1;
			when (new_albumin = .)  albumin_b=.;
			otherwise albuminn_b=.;
		end; 

	*ЛДГ;
		select;
			when (new_ldh < 750) ldh_b = 0;
			when (new_ldh > 750) ldh_b = 1;
			when (new_ldh = .)  ldh_b=.;
			otherwise ldh_b=.;
		end; 


	*Определяем событие смерть в ремиссии;

	if i_rel = 0 and i_death = 1 and i_rem = 1 then rem_death = 1; else rem_death = 0; 

	*if (new_blast_km = .) then BMinv = .;

	label T_class12  = "Вариант ОЛЛ ";
	label T_class124 = "Вариант ОЛЛ ";
	label BMinv = "Поражение костного мозга";

run;

*---------        Исход лечения         ---------;

Data &LN..new_pt;
    set &LN..new_pt;
    Select;
        when (i_rem)       do; TR = 0; TR_date = date_rem;   end;
        when (i_res)       do; TR = 1; TR_date = date_res;   end;
        when (i_ind_death) do; TR = 2; TR_date = date_death; end;
        otherwise;
    end;
run;

*---------        ауто/алло/хемо         ---------;

*value AAC 0 = "Химиотерапия" 1 = "Ауто ТКМ" 2 = "Алло ТКМ" 3 = "Ранний рецидив" 4 = "Смерть в ремиссии" 5 = "на индукции (T < 5 мес)";



data   &LN..new_pt;
    set &LN..new_pt;
	reg = 0;
    if (ownerid = "51362F93-2C7B-E211-A54D-10000001B347") then reg=1; *Ахмерзаева Залина Хатаевна;
	select (tkm_au_al);
		when (1,2) BMT = 1;
		when (0) BMT = 0;
		otherwise;
	end;
	label	BMT = "ТКМ vs Химеотерапия"
			reg = "Где проводилось лечение";
	
run;


data &LN..NLM;
	set &LN..new_pt;
	if not(TR = 0 and (TRF > 6 or tkm_au_al in (1,2)));
	if pr_b > mdy(08,01,13) then onT = 1; else onT = 0;
run;

data &LN..LM;
	set &LN..new_pt;

	if TR = 0 and (TRF > 6 or tkm_au_al in (1,2));

	select (tkm_au_al);
		when (0) 
			do;
				TRF_LM = TRF - 6;
				TLive_LM = TLive - 6;
				Trel_LM = Trel - 6;
			end;
		when (1,2) 
			do;
				TRF_LM = TRF - Ttkm;
				TLive_LM = TLive - Ttkm;
				Trel_LM = Trel - Ttkm;
			end;
		otherwise;
	end;
run; 




/*-----------------------------------------------------------------------------------------------------------*/
/*-----------------------------------------------------------------------------------------------------------*/
/*--------------------------------------------описательная статистика----------------------------------------*/
/*-----------------------------------------------------------------------------------------------------------*/
/*-----------------------------------------------------------------------------------------------------------*/


proc means data = &LN..new_pt N;
	var new_birthdate;
   title 'Всего записей';
run;

proc means data = &LN..new_pt median max min ;
   var age;
   title 'Возраст больных (медиана, разброс)';
run;

proc sort data = &LN..new_pt;
	by age;
run;

proc means data = &LN..new_pt median max min ;
	by age;
   var age;
   title 'Возраст больных (медиана, разброс)';
      format age age_group_f.;
run;


proc freq data=&LN..new_pt ;
   tables new_gendercodename / nocum;
   title 'пол';
run;

proc freq data=&LN..new_pt ;
   tables new_gendercodename*age / nocum;
   title 'пол';
   format age age_group_f.;
run;

proc sort data=&LN..new_pt;
	by new_oll_class;
run;

proc freq data=&LN..new_pt ORDER = DATA;
   tables new_oll_classname / nocum;
   title 'Иммунофенотип (детально)';
run;

proc freq data=&LN..new_pt ; *информация о количестве (без процентов);
   tables oll_class / nocum NOPERCENT;
   title 'Иммунофенотип';
   FORMAT oll_class oc_f.;
run;

proc freq data=&LN..new_pt ; *информация о количестве (без процентов);
   tables oll_class*age / nocum NOPERCENT;
   title 'Иммунофенотип';
   FORMAT oll_class oc_f. age age_group_f.;
run;

data ift; *исключаем из анализа имунофенотипа "неизвестно" и бифенотипический;
	set &LN..new_pt;
	if oll_class in (1,2) then output;
run;

proc freq data=ift ;
   tables oll_class / nocum;
   title 'Иммунофенотип';
   FORMAT oll_class oc_f.;
run;

proc freq data=ift ;
   tables oll_class*age / nocum;
   title 'Иммунофенотип';
   FORMAT oll_class oc_f.;
   format age age_group_f.;
run;

proc means data=&LN..new_pt median max min; 
   var new_l;
   title 'Лейкоциты';
run;
proc sort data = &LN..new_pt;
	by age;
run;

proc means data=&LN..new_pt median max min; 
	by age;
   var new_l;
   title 'Лейкоциты';
   FORMAT age age_group_f.;
run;

proc sgplot data=&LN..new_pt;
	histogram new_l/SCALE= COUNT;
/*  density new_l/ TYPE =  KERNEL;*/
	title 'Лейкоциты';
run;

proc sgplot data=&LN..new_pt;
	by age;
	histogram new_l/SCALE= COUNT;
/*  density new_l/ TYPE =  KERNEL;*/
	title 'Лейкоциты';
	FORMAT age age_group_f.;
run;
proc means data=&LN..new_pt median max min; 
   var new_ldh;
   title 'ЛДГ';
run;

proc means data=&LN..new_pt median max min; 
	by age;
   var new_ldh;
   title 'ЛДГ';
   FORMAT age age_group_f.;
run;

proc sgplot data=&LN..new_pt;
	histogram new_ldh/SCALE= COUNT;
/*  density new_l/ TYPE =  KERNEL;*/
	title 'ЛДГ';
run;

proc sgplot data=&LN..new_pt;
	by age;
	histogram new_ldh/SCALE= COUNT;
/*  density new_l/ TYPE =  KERNEL;*/
	title 'ЛДГ';
	FORMAT age age_group_f.;
run;

proc freq data=&LN..new_pt ;
   tables new_neyrolekname*age / nocum;
   title 'Нейролейкемия';
   format age age_group_f.;
run;


proc freq data=&LN..new_pt ;
   tables new_normkariotipname*age/ nocum;
   title 'Хромосомные аномалии';
  format age age_group_f.;
run;



/*-----------------------------------------------------------------------------------------------------------*/
/*-----------------------------------------------------------------------------------------------------------*/
/*--------------------------------------------  Результаты лечения   ----------------------------------------*/
/*-----------------------------------------------------------------------------------------------------------*/
/*-----------------------------------------------------------------------------------------------------------*/





proc freq data=&LN..new_pt ORDER = DATA;
   tables TR*age / nocum;
   title 'Результаты терапии';
   format TR TR_f. age age_group_f.;
run;

proc freq data=&LN..new_pt ORDER = DATA;
   tables FRint*age / nocum;
   title 'Результаты терапии';
   format age age_group_f.;
run;
/**/
/*proc freq data=&LN..LM ORDER = DATA;*/
/*   tables TR / nocum;*/
/*   title 'Результаты терапии (Ландмарк)';*/
/*   format TR TR_f.;*/
/*run;*/
/**/
/*proc freq data=&LN..NLM ORDER = DATA;*/
/*   tables TR / nocum;*/
/*   title 'Выбраковка (Ландмарк)';*/
/*   format TR TR_f.;*/
/*run;*/
/**/
/*proc freq data=&LN..NLM ORDER = DATA;*/
/*   tables onT / nocum;*/
/*   title 'Выбраковка (Ландмарк) на лечении';*/
/*   format TR TR_f.;*/
/*run;*/

proc freq data=&LN..new_pt ;
   tables TR*age/ nocum;
   title 'Результаты индукционной терапии';
   format age age_group_f. TR TR_f.;
run;

proc freq data=&LN..new_pt ;
   tables  d_ch*new_group_riskname/ nocum;
   title 'Смена на дексаметазон по группам риска';
   format d_ch y_n.;
run;

proc freq data=&LN..new_pt ;
   tables  d_ch*age/ nocum;
   title 'Смена на дексаметазон по возрастным группам';
   format age age_group_f. d_ch y_n.;
run;

proc freq data=&LN..new_pt ;
   tables  new_group_riskname*age/ nocum;
   title 'группы риска по возрастным группам';
   format age age_group_f.;
run;



/*-----------------------------------------------------------------------------------------------------------*/
/*-----------------------------------------------------------------------------------------------------------*/
/*---------------------------------------------- анализ выживаемости ----------------------------------------*/
/*-----------------------------------------------------------------------------------------------------------*/
/*-----------------------------------------------------------------------------------------------------------*/


%eventan (&LN..new_pt, TLive, i_death, 0,,&y,age,age_group_f.,"стратификация по возрасту. Выживаемость");
%eventan (&LN..new_pt, TRF, iRF, 0,,&y,age,age_group_f.,"стратификация по возрасту. Безрецидивная выживаемость");

data boll;
	set &LN..new_pt;
		if (oll_class = 1);
run;

%eventan (boll, TRF, iRF, 0,,&y,new_normkariotip,yn_e.,"Стратификация по кариотипу. Безрецидивная выживаемость");


/*-----------------------------------------------------------------------------------------------------------*/
/*-----------------------------------------------------------------------------------------------------------*/
/*------------------------------------------ Мультивариантный анализ ----------------------------------------*/
/*-----------------------------------------------------------------------------------------------------------*/
/*-----------------------------------------------------------------------------------------------------------*/


/*6.  Мультивариантный анализ (отдельно для В-ОЛЛ, Т-ОЛЛ, и потом для всех*/
/*вместе):*/
/**/
/*А. Достижение полной ремиссии и смерть в период индукции(параметры, которые надо включить в анализ:*/
/**/
/*пол, возраст, иммунофенотип, группа риска, */
/*- число лейкоцитов для В-ОЛЛ 30 тыс и более, для Т-ОЛЛ 100 тыс и более, */
/*- число тромбоцитов - ???, */
/*- креатинин более 120, */
/*- билирубин более 30, */
/*- альбумин менее 35, */
/*- смена на дексаметазон, */
/*- нормальный кариотип или аномальный, */
/*- ЛДГ более 750*/
/**/
/*Б. Общая выживаемость */
/*- пол, возраст (до 30 и с 30 и старше), */
/*- иммунофенотип, */
/*- группа риска, */
/*- ЛДГ более 750, */
/*- число лейкоцитов для В-ОЛЛ 30 тыс и более, для Т-ОЛЛ 100 тыс и более, */
/*- смена на дексаметазон, */
/*- нормальный кариотип или аномальный, */
/*- достижение ремиссии после 1 (включая предфазу) или 2-й фазы лечения, */
/*- выполнение аутологичной ТКМ, - выполнение аллогенной ТКМ*/
/**/
/*В. Безрецидивная выживаемость */
/*- пол, */
/*- возраст (до 30 и с 30 и старше), */
/*- иммунофенотип, */
/*- группа риска, */
/*- ЛДГ более 750, */
/*- число лейкоцитов для В-ОЛЛ 30 тыс и более, для Т-ОЛЛ 100 тыс и более, */
/*- смена на дексаметазон, */
/*- нормальный кариотип или аномальный, */
/*- достижение ремиссии после 1 (включая предфазу) или 2-й фазы лечения,*/
/*- полная отмена Л-аспарагиназы, */
/*- выполнение аутологичной ТКМ, */
/*- выполнение аллогенной ТКМ*/


/*proc phreg data=a; 
	model ВРЕМЯ*ИНДИКАТОР_ЦЕНЗУРИРОВАНИЯ(0)= ФАКТОР1 ФАКТОР2; 
run; */

proc phreg data=&LN..LM; 
	model TLive_LM*i_death(0)=reg new_vnutrigrud_ulu	new_splenomeg BMT  BMinv	/ selection = s slentry = .3 slstay = .15;  
	title "Ландмарк.  Общая выживаемость";
run; 

proc phreg data=&LN..LM; 
	model TRF_LM*iRF(0)= BMT reg new_normkariotip FRint new_molegen	BMinv
new_mogen_tcr	
new_mogen_igh	
new_mogen_t922	
new_mogen_t411		
new_neyrolek	
new_splenomeg	
new_gepatomeg	
new_uvsredosten	
new_inf_donow_ter	
new_gemorag_sindr	
new_peref_ulu	
new_vnutrigrud_ulu	
new_abdomi_ulu	
new_ekstramod	
new_skin_eo	
new_gonad_eo	
new_testis_eo	
new_intratumor_eo	/ selection = s slentry = .3 slstay = .15;  
	title "Ландмарк. Безрецидивная выживаемость";
run; 

proc phreg data=&LN..LM; 
	model Trel_LM*i_rel(0)= BMT reg new_normkariotip FRint new_molegen	BMinv
new_mogen_tcr	
new_mogen_igh	
new_mogen_t922	
new_mogen_t411		
new_neyrolek	
new_splenomeg	
new_gepatomeg	
new_uvsredosten	
new_inf_donow_ter	
new_gemorag_sindr	
new_peref_ulu	
new_vnutrigrud_ulu	
new_abdomi_ulu	
new_ekstramod	
new_skin_eo	
new_gonad_eo	
new_testis_eo	
new_intratumor_eo	/ selection = s slentry = .3 slstay = .15;   
	title "Ландмарк. Вероятность развития рецидива";
run; 

