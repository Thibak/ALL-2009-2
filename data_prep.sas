/***********************************************************************************************************/
/***********************************************************************************************************/
/***********************************************************************************************************/
/***********************************************************************************************************/
/*****************                                                                       *******************/
/****************                      Отчет по протоколу ОЛЛ-2009                        ******************/
/*****************                                                                       *******************/
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
filename tranfile "&disk.:\AC\OLL-2009\prep_lib\&sysdate9..stc"; * условный идентификатор транспортного файла;

%let y = cl;
%let cens = (20,73,25);
/*Исключаем - Марханова, Позднякова, Чубукова*/
/*25 -- Марханов (Марханов был снят с протокола еще в 10-м году (его лечили бог знает как).)*/
/*73 -- Чубуков (у Чубукова вообще другой диагноз - миелоидная саркома)*/
/*266	Дмитровский В.Б. -- Дмитровского не надо исключать - у него только правильно не отмечено время достижения полной ремиссии и дата ТКМ. Он правильный больной с неправильными датами*/
/*20	Поздняков Нет данных Нет данных*/
/*27 -- Головнитцына -- Головнитцына включена, но умерла до лечения. Ее исходне данные можно включать, а в анализе выживаемости и результатах лечения не участвует.*/
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
		pt_id = 'идентификатор'
		name = 'имя'
		i_death = 'смерть'
		i_ind_death = 'смерть в индукции'
		i_rel = 'рецедив'
		i_dev = 'отклонение от протокола'
		dev_t = 'отклонения - комментариий'
		i_off = 'преждевременное снятие с протокола'
		off_t = 'снятие -- комментарий'
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
		new_inf_comp_8 = pneumonia
		new_inf_comp_6 = NEP
		new_inf_comp_9 = sepsis
		new_inf_comp_16 = invasp
		new_aspor_vvod = a_vvod
		new_aspor_pankr = a_pankr
		new_aspor_gepat = a_gepat
		new_aspor_narbelsint = a_narbelsint
		new_aspor_tromb = a_tromb
		new_aspor_occhuv = a_occhuv
		new_aspor_perehod = a_perehod
		new_aspor_otmena = a_otmena

        ;
	label
		pneumonia = 'пневмония'
		NEP = 'Некротическая Энтеропатия'
		sepsis = 'Сепсис'
		invasp = 'Инвазивный аспергиллез'
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


data &LN..cens;
	set &LN..all_pt;
	if pt_id in &cens then output;
run;

/*proc print data = cens split='*' N;*/
/*	var pt_id name;*/
/*	label pt_id = 'Номер пациента*в протоколе'*/
/*          name = 'Имя*в базе пациентов';*/
/*	title "Из базы принудительно исключены следующие записи" ;*/
/*run;*/

/*data null;*/
/*	set &LN..all_pt;*/
/*	if pt_id = . then output;*/
/*run;*/
/**/
/*proc print data = null split='*' N;*/
/*	var pt_id name;*/
/*	label pt_id = 'Номер пациента*в протоколе'*/
/*          name = 'Имя*в базе пациентов';*/
/*	title "В базе не имеют номера в протоколе" ;*/
/*run;*/


/*Исключаем записи повторного подтверждения ремиссии*/


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

data &LN..all_pt &LN..age_out; 
    set &LN..all_pt;
	if age<=60 and age>=15 then output &LN..all_pt;
	else output &LN..age_out;
run;






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
    retain 
		ec d_ch time_error 
		preph_bg preph_end 
		ind1bg ind1end 
		ind2bg ind2end
		pneumonia_i
		NEP_i
		sepsis_i
		invasp_i
		a_vvod_i
		a_pankr_i
		a_gepat_i
		a_narbelsint_i
		a_tromb_i
		a_occhuv_t
		a_perehod_i
		a_otmena_i
		; *ec -- это количество этапов "свернутых";
    if first.pguid then 
		do;  
			ec = 0; 
			d_ch = .;  
			time_error = .; 
			preph_bg = .;
			preph_end = .;
			ind1bg = .; 
			ind1end = .; 
			ind2bg = .; 
			ind2end = .; 
			pneumonia_i = 0; 
			NEP_i = 0; 
			sepsis_i = 0; 
			invasp_i = 0; 
			a_vvod_i = .; 
			a_pankr_i = 0; 
			a_gepat_i = 0; 
			a_narbelsint_i = 0; 
			a_tromb_i = 0; 
			a_occhuv_t = .; 
			a_perehod_i = 0; 
			a_otmena_i = 0; 
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
		preph_bg = ph_b; 
		preph_end = ph_e;
		end;
	if new_etap_protokol = 2 then do; ind1bg = ph_b; ind1end = ph_e; end;
	if new_etap_protokol = 3 then do; ind2bg = ph_b; ind2end = ph_e; end;

	if 	pneumonia = 1 then pneumonia_i = 1; 
	if 	NEP = 1 then NEP_i = 1; 
	if 	sepsis = 1 then sepsis_i = 1;
	if 	invasp = 1 then invasp_i = 1; 

	if	a_vvod ne . then a_vvod_i = a_vvod;
	if 	a_pankr = 1 then a_pankr_i = 1;
	if 	a_gepat = 1 then a_gepat_i = 1;
	if 	a_narbelsint = 1 then a_narbelsint_i = 1;
	if 	a_tromb = 1 then a_tromb_i = 1; 
	if 	a_occhuv ne . then a_occhuv_t = a_occhuv;
	if 	a_perehod = 1 then a_perehod_i = 1;
	if 	a_otmena = 1 then a_otmena_i = 1;

/*---------------------------------------------------*/
    if last.pguid then
        do;
			*if time_error ne . then output &LN..error_timeline;

            output &LN..new_pt;
            d_ch = .;
			time_error = .;
			preph_bg = .;
			preph_end = .;
			ind1bg = .; 
			ind1end = .; 
			ind2bg = .; 
			ind2end = .;
			pneumonia_i = 0; 
			NEP_i = 0; 
			sepsis_i = 0; 
			invasp_i = 0;  
			a_vvod_i = .; 
			a_pankr_i = 0; 
			a_gepat_i = 0; 
			a_narbelsint_i = 0; 
			a_tromb_i = 0; 
			a_occhuv_t = .; 
			a_perehod_i = 0; 
			a_otmena_i = 0; 
        end;
	label 
		d_ch = "Смена на дексаметазон"
		pneumonia_i = 'Пневмония'
		NEP_i = 'Некротическая Энтеропатия'
		sepsis_i =  'Сепсис'
		invasp_i =   'Инвазивный аспергиллез'
		a_vvod_i = "На каком по счету введении (с момента начала лечения по протоколу) (Токсичность на аспарагиназу)"
		a_pankr_i = 'Панкреатит на Л-асп (Токсичность на аспарагиназу)'
		a_gepat_i = 'Гепатит (билир, АЛТ, АСТ) (Токсичность на аспарагиназу)'
		a_narbelsint_i = 'Нарушение белк.синт. Функции (ПИ, фибр, АТ III, Альб) (Токсичность на аспарагиназу)'
		a_tromb_i = 'Тромбозы (Токсичность на аспарагиназу)'
		a_occhuv_t = 'Оценка выраженности гиперчувствительности к аспарагиназе (Токсичность на аспарагиназу)'
		a_perehod_i = 'Переход на ПЭГ - аспарагиназу (Токсичность на аспарагиназу)'
		a_otmena_i =  'Отмена аспарагиназы на все послед. этапы лечения (Токсичность на аспарагиназу)'
		;
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
    retain i_rem date_rem FRint /**/ 
		i_death date_death i_ind_death /**/
		i_tkm date_tkm tkm_au_al/**/ 
		i_rel date_rel rel_t/**/ 
		i_res date_res /**/ 
		i_dev  dev_t
		i_off off_t 

		Laspot;
    if first.pguid then 
		do; 
			i_rem = 0; date_rem = .; FRint = .; 
			i_res = 0; date_res = .; 
			i_death = 0; date_death = .; i_ind_death = 0; 
			i_tkm = 0; date_tkm = .; tkm_au_al = 0;
			i_rel = 0; date_rel = .; rel_t = '';
			i_dev = 0; dev_t = '';
			i_off = 0; off_t = '';
			Laspot = 0; 
		end;
/*----------------------------------*/
    if new_event = 1 then 
		do; 
			i_rem = 1; 
			date_rem = new_event_date; 

			*если нет даты начала терапии, предполагаем, что все идет по регламенту;
			FRint = new_remissetap;

/*			select;			*/
/*				when (preph_bg <= date_rem <= preph_end+15) FRint = 0;*/
/*				when (ind1bg+15 <= date_rem <= ind1end+15) FRint = 1; *склеиваем этапы;*/
/*				*when (ind1bg-2 <= date_rem <= ind2bg +2 ) FRint = 1; *склеиваем этапы;*/
/*				when (ind2bg+15   <= date_rem <= ind2end+2) FRint = 2;  */
/*				otherwise FRint = 9;*/
/*			end;*/
		end;
	if new_event = 2 then do; i_res = 1; date_res = new_event_date; end;
    if new_event = 3 then do; i_death = 1; date_death = new_event_date; end;
	 if new_event_txt = "В индукции" then i_ind_death = 1; 
	if new_event = 4 then do; i_tkm = 1; date_tkm = new_event_date; end;
	 if new_event_txt = "ауто" then tkm_au_al = 1; 
	 if new_event_txt in ("алло - родственная","алло - неродственная")  then tkm_au_al = 2;
    if new_event = 5 then do; i_rel = 1; date_rel = new_event_date; rel_t = new_event_txt; end;
	if new_aspor_otmena = 1 then laspot = 1;
	if new_event = 6 then do; 
			i_dev = 1; 
			dev_t = new_event_txt; 
			if new_event_txt = "Отказ от лечения" then do;
				lastdate = new_event_date;
				if date_rel > lastdate then i_rel = 0;
				if date_rem > lastdate then i_rem = 0;
				if date_tkm > lastdate then i_tkm = 0;
				if date_death > lastdate then i_death = 0;
				END;
			end;
	if new_event = 7 then do; i_off = 1; off_t = new_event_txt; end;
/*---------------------------------*/
    if last.pguid then 
		do; 
			if ie1 ne 0 then  output; *<-----------------------;
			i_rem = 0; date_rem = .; FRint = .;
			i_res = 0; date_res = .; 
			i_death = 0; date_death = .; i_ind_death = 0; 
			i_tkm = 0; date_tkm = .; tkm_au_al = 0;
			i_rel = 0; date_rel = .; rel_t = '';
			i_dev = 0; dev_t = '';
			i_off = 0; off_t = '';
			Laspot = 0; 
		end;
	label date_death = "Дата смерти"
		new_group_risk = "группа риска"
		new_normkariotip = "Normal karyotype"
		pt_id = "идентификатор"
		name = "имя"
		i_death = "смерть"
		i_ind_death = "смерть в индукции"
		i_rel = "рецедив"
		i_dev = "отклонение от протокола"
		dev_t = "отклонения - комментариий"
		i_off = "преждевременное снятие с протокола"
		off_t = "снятие -- комментарий"
		;
run;





*убираем цензурированные записи;
data &LN..new_pt;
	set &LN..new_pt;
	if ie1 ne 0;
run;
	
/*Запаска на случай необходимости */
data &LN..no_TR; 
	set &LN..new_pt;
	if i_rem = 0 and i_ind_death = 0 and i_res = 0 then output;
run;


/*поставить заплатку если время рецидива равно нулю то сегодняшняя дата <----------- ЕСТЬ ЛИ ЭТО????*/
/*обновление последнего контакта за счет смерти*/ 
/*всякие досчеты */
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
	ver_rel = 0;
	if i_rel = 1 then ver_rel = 1;
	year = year(pr_b);
	if 
		new_peref_ulu = 1 or
		new_vnutrigrud_ulu = 1 or
		new_abdomi_ulu = 1 
	then lap = 1; else lap = 0;
	label lap = 'Лимфаденопатия'
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

	if (i_tkm) then do;
			Ttkm = (date_tkm - date_rem)/30;
			tkm_dur = (date_tkm - pr_b)/30;
			end;
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

		select;
			when (age < 30) ageg = 0;
			when (age >= 30) ageg = 1;
			otherwise ageg=.;
		end; 
	*заслуживающие доверия записи;
/*		veritable records -- vr*/

		if (new_hb ne . or	new_l ne . or	new_tp ne . or	new_blast_km ne . or	new_blast_pk ne . or	new_creatinine ne . or	new_bilirubin ne . or	new_ldh ne . or	new_albumin ne . or	new_protromb_ind ne . or	new_dlin_rs ne . or	new_poperech_rs )
then vr = 1; else vr = 0;

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
		when (i_ind_death) do; TR = 2; TR_date = date_death; end;
        when (i_res)       do; TR = 1; TR_date = date_res;   end;
		when (i_rem)       do; TR = 0; TR_date = date_rem;   end;
        otherwise;
    end;
	if new_normkariotip = 0 and new_t922 in (.,0) and new_bcrabl in (.,0) and new_t411name in (.,0) then kario = 1;
	if new_normkariotip = 1 or new_t922 = 1 or new_bcrabl  = 1 or new_t411name  = 1 then kario = 0;
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
	if pr_b > mdy(06,01,14) then onT = 1; else onT = 0;
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

data &LN..new_pt;  
	set &LN..new_pt;
	TD = (lastdate - pr_b)/30;
run;

data &LN..vr_pt;
	set &LN..new_pt;
	if vr;
run;

data &LN..boll;
	set &LN..new_pt;
	if (oll_class = 1);
run;


data &LN..boll_LM;
	set &LN..LM;
	if (oll_class = 2);
run;

data &LN..boll_NLM;
	set &LN..NLM;
	if (oll_class = 2);
run;

data &LN..bcito;
	set &LN..boll ;
	if new_citogen = 1;
run;

data &LN..boll_LM_xa;
	set &LN..boll_LM;
	if tkm_au_al in (0,1);
run;

data &LN..toll;
	set &LN..new_pt;
	if (oll_class = 2);
run;

data &LN..toll_LM;
	set &LN..LM;
	if (oll_class = 2);
run;

data &LN..toll_NLM;
	set &LN..NLM;
	if (oll_class = 2);
run;

data &LN..tcito;
	set &LN..toll ;
	if new_citogen = 1;
run;

data &LN..tLMcito;
	set &LN..toll_LM ;
	if new_citogen = 1;
run;


data &LN..toll_LM_xa;
	set &LN..toll_LM;
	if tkm_au_al in (0,1);
run;



*загоняем в транспортный файл;
proc cport library=&LN file=tranfile;
run;

/**/
/*proc sort data=all2009.new_pt;*/
/*	by pt_id;*/
/*run;*/
/**/
/*proc print data=all2009.new_pt;*/
/*	var pt_id name;*/
/*run;*/
