
/***********************************************************************************************************/
/***********************************************************************************************************/
/***********************************************************************************************************/
/***********************************************************************************************************/
/*****************                                                                       *******************/
/****************                      ����� �� ��������� ���-2009                        ******************/
/*****************                          ������ �� �-���                              *******************/
/***********************************************************************************************************/
/***********************************************************************************************************/
/***********************************************************************************************************/
/***********************************************************************************************************/
/*������������� �����*/ *D - sony, Z - ���;
*��� ���������� ����������� �� ��������;
%let disk = .;
%let lastname= .;
%macro what_OC;
%if &sysscpl = W32_7PRO %then 
	%do;
		%let disk = D; *sony;
	%end;
%if &sysscpl = X64_7PRO %then 
	%do;
		%let disk = Z; *������;
	%end;
%mend;


/*������������ ��*/
/*data comp;*/
/*	OC = "&sysscpl";*/
/*run;*/
/**/
/*proc print data = COMP;*/
/*run;*/
%what_OC;

%let LN = ALL2009; * ��� ����������;
Libname &LN "&disk.:\AC\OLL-2009\SAS"; * ���������� ������;
%let y = cl;
%let cens = (20);
*20, 27, 99, 132, 258, 264;

%macro Eventan(dat,T,C,i,s,cl,f,for, ttl);
/*
Eventan(dat,T,C,i,s,cl,f,for, ttl)
dat - ��� ������ ������,
T   - �����,
C   - ������ �������/��������������,
i   - ������������ ��������������
	i = 0, ���� � ������ �������,
	i = 1, ���� � ������ ��������������.
s   - �����,���� �������� ������ ������������
	s = F, ���� �������� ������ ����������� �����������
cl  - �����,���� �� ���������� ������������� ��������
	cl = cl, ���� ���������� ������������� ��������
f   - ������ (������) ���� ����� �� ��� ������
for - ������ (1.0 ��� ������������� ��������, ����� ��� ������������ �������)
ttl - ���������
*/

data _null_; set &dat;
   length tit1 $256 tit2 $256;
*������ ��������;
tit1=vlabel(&T);
%if &f ne %then %do; tit2=vlabel(&f);%end;
   * �������� ������� � ���������������;
   call symput('tt1',tit1);
   call symput('tt2',tit2);
output;
   stop;
   keep tit1 tit2;
run;
title1 &ttl;
title2 " ���������:  &tt1 // ������       :  &tt2";
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
    value oc_f  1 = "B-���������" 2 = "T-���������" 3 = "����������������" 0 = "����������" ;
    value gender_f 1 = "�������" 2 = "�������";
    value risk_f 1 = "�����������" 2 = "�������" 3 = "��� ������";
    value age_group_28_f low-28 = "�� 28-�� ���" 28-high = "����� 28-�� ���";
    value age_group_30_f low-30 = "�� 30-�� ���" 30-high = "����� 30-�� ���";
    value age_group_33_f low-33 = "�� 33-� ���" 33-high = "����� 33-� ���";
	value age_group_f low-29 = "AYA" 29-high = "Adult";
	value triple_age_f low-30 = "1" 30-40 = "2" 40-high = "3";
	value tkm_f 0="���" 1="����" 2="����";
	value it_f 1="����" 0 = "���";
	value time_error_f . = "��� ������" 
		0 = "���� ���������� ������ �� ���������" 
		1 = "���� ���������� ������� (�����) ������ ��� ���� ���������� ��������" 
		2 = "���� �������� ������ ���� ���������� ��������" 
		3 = "���� �������� ������ ���� ���������� ��������"
		4 = "date bmt > lastdate";

/*	  if date_rem > lastdate then do; time_error = 2; lastdate = date_rem; end;*/
/*    if date_rel > lastdate then do; time_error = 3; lastdate = date_rel; end;*/
	value new_group_risk_f 1 = "�����������" 2 = "�������";
	value y_n 0 = "���" 1 = "��";
	value yn_e 0 = "no" 1 = "yes";
	value au_al_f 1 = "����" 2 = "���� - �����������" ;
	value reg_f 0 = "�������" 1 = "���"; 
	value T_class12_f 0 = "T1+T2" 1 = "T3" 2 = "T4";
	value T_class124_f 0 = "T1+T2+T4" 1 = "T3";
	value TR_f 0 = "������ ��������" 1 = "������������ �����" 2 = "������ � ��������";
	value BMinv_f 0 = "��� ���������" 1 = "� ����������";
	value AAC_f 0 = "������������" 1 = "���� ���" 2 = "���� ���" 3 = "������ �������" 4 = "������ � ��������" 5 = "�� �������� (T < 5 ���)";
	value FRint_f 0 = "�� �� ������ ����" 1 = "�� �� 1-�� ���� ��������" 2 = "�� �� 2-�� ���� ��������";
	value BMT_f 0 = "������������" 1 = "���";
	value tkm_au_al_f 0 = "������������" 1="����-���" 2="����-���";
run;

/*------------ ������������� �������������� ������� � ����������� ������ ---------------*/
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
		new_group_risk = "������ �����"
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
/*------ ��������������, � ���������� ����������� ����������� ----------*/


data cens;
	set &LN..all_pt;
	if pt_id in &cens then output;
run;

proc print data = cens split='*' N;
	var pt_id name;
	label pt_id = '����� ��������*� ���������'
          name = '���*� ���� ���������';
	title "�� ���� ������������� ��������� ��������� ������" ;
run;

data null;
	set &LN..all_pt;
	if pt_id = . then output;
run;

proc print data = null split='*' N;
	var pt_id name;
	label pt_id = '����� ��������*� ���������'
          name = '���*� ���� ���������';
	title "� ���� �� ����� ������ � ���������" ;
run;

proc sort data=&LN..all_pt;
	by pt_id;
run;


/*----- ��������� �������� ��������. �� ������ �� ��������� ��������, ��� ��� ��� ������ ���������� ������� �� ����*/
/*-- ���������� ������ �� &LN..rps --*/
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


data &LN..all_pt; *������ �� ������� ���������;
    set &LN..all_pt;

	if new_group_risk = 3 then new_group_risk = .; * 3 -- ��� ��� "��� ������", ��� ���������� ���������� ������!;



if age = . then age = floor(yrdif(new_birthdate, pr_b,'AGE'));  *���� �������� ��� � ���� ��, �� ���������������� � ���� �� ���� �������� ������ ���������;
    *FORMAT age 2.0;

/*-------------------*/

    /* ��� ������� */
    select;
        when (new_oll_class in (1,2,3) )   oll_class = 1; /*B-OLL*/
        when (new_oll_class in (5,6,7,8) ) oll_class = 2; /*T-OLL*/
        when (new_oll_class = 99)  oll_class = 0; /*����������*/
        when (new_oll_class = 9 )  oll_class = 3; /*���������������*/
        otherwise;
    end;

/*����������� ������*/


/* ������ �������������� ������*/
    if NOT (pt_id in &cens ) then output;
run;


footnote " ";




/*-----------------------------------���� �������� ������� �� ������----------------------*/
proc sort data=&LN..all_et;
    by pguid new_etap_protokol; *��������� ������� ������ �� ID ��������� � �� ������ ��������� (� ��������������� �������);
run;

proc sort data=&LN..all_pt;
    by pguid; *��������� ������� ������ �� ID ��������� � �� ������ ��������� (� ��������������� �������);
run;

/*��������� ������� ��������� � ������, ���������� ��� ���� �� ��������� ��� ������ �� ������*/
data &LN..new_et;
    merge &LN..all_pt (in = i1) &LN..all_et (in = i2);
    by pguid;

    it1 = i1;
    it2 = i2;
run;

*������� ��������������� ������;
data &LN..new_et;
	set &LN..new_et;
	if it1 ne 0;
run;



/*����������� ��������� �������, ��� ������ ��������� ������ �������� ����� �� ������������, � ����� �����. ��������� ������� � �������*/
data &LN..new_pt /*(keep=)*/;
    set &LN..new_et;
    by pguid;
    retain ec d_ch time_error ind1bg ind1end ind2bg ind2end; *ec -- ��� ���������� ������ "���������";
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

    if ph_b > lastdate and time_error = 0 then do; lastdate = ph_b; end; *�������� �� ��������� ����. ;
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
	label d_ch = "����� �� ������������";
run;

data &LN..new_pt;
	set &LN..new_pt;
			if (ind1bg  = .) then ind1bg  = pr_b + 7; 
			if (ind1end = .) then ind1end = ind1bg + 36;
			if (ind2bg  = .) then ind2bg  = ind1end;
			if (ind2end = .) then ind2end = ind1bg + 70;
run;


/*��������� �� ������� �������� �������-����*/

proc sort data = &LN..error_ptVSet;
	by pt_id;
run;

data &LN..error_ptVSet;
	set &LN..new_et (keep = pt_id name name_e new_etap_protokolname it1 it2);
	if it1 ne it2 then output; 
run;

proc print data = &LN..error_ptVSet split='*' N obs="�����*������";
	var pt_id name name_e new_etap_protokolname it1 it2;
	label pt_id = '����� ��������*� ���������'
          name = '���*� ���� ���������'
          name_e = '���*� ���� ������'
		  new_etap_protokolname = '����'
		  it1 = '������*� ���� ���������' 
		  it2 = '������* � ���� ������';
	title "������ � ���� (���� ������� - ����)" ;
	format  it1 it2 it_f. ; 
run;

/*----------------------------------------------------------------------------------------*/





/*-------------------------- ���������� ���������� ��� ����������� ������� ----------------------------*/

/*����������� ������� ������� � ������ ��� �������������, ������� ������ ������*/
proc sort data=&LN..all_ev;
    by pguid new_event new_event_date ;
run;



data &LN..all_ev_red;
	set &LN..all_ev;
	by pguid new_event new_event_date ;
	if first.new_event then output;
run;


/*���������� ������� � ���������. ��� ����� ���������� � ���� �������� � ������*/

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

/*  rem �������� = 1 */
/*  res �������������� = 2*/
/*  death ������ = 3*/
/*  tkm ��� = 4*/
/*  rel ������� = 5*/


/*--- ���������� ���������� ��������/��������/������ ---*/
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

			*���� ��� ���� ������ �������, ������������, ��� ��� ���� �� ����������;


			select;
				when (ind1bg-10 <= date_rem <= ind1end+15) FRint = 1; *��������� �����;
				*when (ind1bg-2 <= date_rem <= ind2bg +2 /*ind1end*/) FRint = 1; *��������� �����;
				when (ind2bg+15   <= date_rem <= ind2end+2) FRint = 2;  
				otherwise FRint = 0;
			end;
		end;
	if new_event = 2 then do; i_res = 1; date_res = new_event_date; end;
    if new_event = 3 then do; i_death = 1; date_death = new_event_date; end;
	 if new_event_txt = "� ��������" then i_ind_death = 1; 
	if new_event = 4 then do; i_tkm = 1; date_tkm = new_event_date; end;
	 if new_event_txt = "����" then tkm_au_al = 1; 
	 if new_event_txt in ("���� - �����������","���� - �������������")  then tkm_au_al = 2;
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

*������� ��������������� ������;
data &LN..new_pt;
	set &LN..new_pt;
	if ie1 ne 0;
run;
	

/*��������� �������� ���� ����� �������� ����� ���� �� ����������� ���� <----------- ���� �� ���????*/
/*���������� ���������� �������� �� ���� ������*/  
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

/*������������*/
/*��������� � ������*/
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

/*������������� ������������*/
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

*���������� ����� ������;

Data &LN..new_pt;
    set &LN..new_pt;
    select (new_oll_class);
        when (5) do; T_class12 = 0 ; T_class124 = 0 ; end;  *T1;
		when (6) do; T_class12 = 0 ; T_class124 = 0 ; end; *T2;
		when (7) do; T_class12 = 1 ; T_class124 = 1; end; *T3;
		when (8) do; T_class12 = 2 ; T_class124 = 0; end; *T4;
        otherwise;
    end;
	
*����������� ����� ���������� ����������;

	*�������� ������;
	Select; 
		when (blast_km => 5) BMinv = 1; 
		when (blast_km = .) BMinv = .;
		when (blast_km  < 5) BMinv = 0;
		otherwise;
	end; 

	*���������;
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

	*���������;
		select;
			when (new_creatinine < 120) creatinine_b = 0;
			when (new_creatinine > 120) creatinine_b = 1;
			when (new_creatinine = .)   creatinine_b=.;
			otherwise creatinine_b=.;
		end; 

	*���������;
		select;
			when (new_bilirubin < 30) bilirubin_b = 0;
			when (new_bilirubin > 30) bilirubin_b = 1;
			when (new_bilirubin = .)  bilirubin_b=.;
			otherwise bilirubin_b=.;
		end; 

	*��������;
		select;
			when (new_albumin > 35) albumin_b = 0;
			when (new_albumin < 35) albumin_b = 1;
			when (new_albumin = .)  albumin_b=.;
			otherwise albuminn_b=.;
		end; 

	*���;
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
	*������������� ������� ������;
/*		veritable records -- vr*/

		if (new_hb ne . or	new_l ne . or	new_tp ne . or	new_blast_km ne . or	new_blast_pk ne . or	new_creatinine ne . or	new_bilirubin ne . or	new_ldh ne . or	new_albumin ne . or	new_protromb_ind ne . or	new_dlin_rs ne . or	new_poperech_rs )
then vr = 1; else vr = 0;

	*���������� ������� ������ � ��������;

	if i_rel = 0 and i_death = 1 and i_rem = 1 then rem_death = 1; else rem_death = 0; 

	*if (new_blast_km = .) then BMinv = .;

	label T_class12  = "������� ��� ";
	label T_class124 = "������� ��� ";
	label BMinv = "��������� �������� �����";

run;


*---------        ����� �������         ---------;

Data &LN..new_pt;
    set &LN..new_pt;
    Select;
        when (i_rem)       do; TR = 0; TR_date = date_rem;   end;
        when (i_res)       do; TR = 1; TR_date = date_res;   end;
        when (i_ind_death) do; TR = 2; TR_date = date_death; end;
        otherwise;
    end;
run;

*---------        ����/����/����         ---------;

*value AAC 0 = "������������" 1 = "���� ���" 2 = "���� ���" 3 = "������ �������" 4 = "������ � ��������" 5 = "�� �������� (T < 5 ���)";



data   &LN..new_pt;
    set &LN..new_pt;
	reg = 0;
    if (ownerid = "51362F93-2C7B-E211-A54D-10000001B347") then reg=1; *���������� ������ ��������;
	select (tkm_au_al);
		when (1,2) BMT = 1;
		when (0) BMT = 0;
		otherwise;
	end;
	label	BMT = "��� vs ������������"
			reg = "��� ����������� �������";
	
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


data &LN..vr_pt;
	set &LN..new_pt;
	if vr;
run;

data &LN..boll;
	set &LN..new_pt;
	if (oll_class = 1);
run;

data &LN..toll;
	set &LN..new_pt;
	if (oll_class = 2);
run;
/*-----------------------------------------------------------------------------------------------------------*/
/*-----------------------------------------------------------------------------------------------------------*/
/*--------------------------------------------������������ ����������----------------------------------------*/
/*-----------------------------------------------------------------------------------------------------------*/
/*-----------------------------------------------------------------------------------------------------------*/


proc means data = &LN..new_pt N;
	var new_birthdate;
   title '����� �������';
run;

proc freq data=&LN..new_pt ORDER = DATA;
   tables vr / nocum;
   title '������������� ������� �������';
run;

proc means data = &LN..new_pt median max min ;
   var age;
   title '������� ������� (�������, �������)';
run;

proc sort data = &LN..new_pt;
	by age;
run;

proc means data = &LN..new_pt median max min ;
	by age;
   var age;
   title '������� ������� (�������, �������)';
      format age age_group_f.;
run;


proc freq data=&LN..new_pt ;
   tables new_gendercodename / nocum;
   title '���';
run;

proc freq data=&LN..new_pt ;
   tables new_gendercodename*age / nocum;
   title '���';
   format age age_group_f.;
run;

proc sort data=&LN..new_pt;
	by new_oll_class;
run;

proc freq data=&LN..new_pt ORDER = DATA;
   tables new_oll_classname / nocum;
   title '������������� (��������)';
run;

proc freq data=&LN..new_pt ; *���������� � ���������� (��� ���������);
   tables oll_class / nocum NOPERCENT;
   title '�������������';
   FORMAT oll_class oc_f.;
run;

proc freq data=&LN..new_pt ; *���������� � ���������� (��� ���������);
   tables oll_class*age / nocum NOPERCENT;
   title '�������������';
   FORMAT oll_class oc_f. age age_group_f.;
run;

data ift; *��������� �� ������� ������������� "����������" � ����������������;
	set &LN..new_pt;
	if oll_class in (1,2) then output;
run;

proc freq data=ift ;
   tables oll_class / nocum;
   title '�������������';
   FORMAT oll_class oc_f.;
run;

proc freq data=ift ;
   tables oll_class*age / nocum;
   title '�������������';
   FORMAT oll_class oc_f.;
   format age age_group_f.;
run;

proc means data=&LN..new_pt median max min; 
   var new_l;
   title '���������';
run;
proc sort data = &LN..new_pt;
	by age;
run;

proc means data=&LN..new_pt median max min; 
	by age;
   var new_l;
   title '���������';
   FORMAT age age_group_f.;
run;

proc sgplot data=&LN..new_pt;
	histogram new_l/SCALE= COUNT;
/*  density new_l/ TYPE =  KERNEL;*/
	title '���������';
run;

proc sgpanel data=&LN..new_pt;
 panelby age /
    uniscale=row;
 histogram new_l/SCALE= COUNT;
 FORMAT age age_group_f.;
run;

proc means data=&LN..new_pt median max min; 
   var new_ldh;
   title '���';
run;

proc means data=&LN..new_pt median max min; 
	by age;
   var new_ldh;
   title '���';
   FORMAT age age_group_f.;
run;

proc sgplot data=&LN..new_pt;
	histogram new_ldh/SCALE= COUNT;
/*  density new_l/ TYPE =  KERNEL;*/
	title '���';
run;

proc sgpanel data=&LN..new_pt;
 panelby age /
    uniscale=row;
 histogram new_lDH/SCALE= COUNT;
 FORMAT age age_group_f.;
run;


/*������� ���������� ������ ��� ���, � ���� ����������� ���������. �.�. ������ ������� ����� ��������, ��� "����������� ����������� ������"*/

proc freq data=&LN..vr_pt ;
   tables new_neyrolekname*age / nocum;
   title '�������������';
   format age age_group_f.;
run;


proc freq data=&LN..new_pt ;
   tables new_normkariotipname*age/ nocum;
   title '����������� ��������';
  format age age_group_f.;
run;



/*-----------------------------------------------------------------------------------------------------------*/
/*-----------------------------------------------------------------------------------------------------------*/
/*--------------------------------------------  ���������� �������   ----------------------------------------*/
/*-----------------------------------------------------------------------------------------------------------*/
/*-----------------------------------------------------------------------------------------------------------*/





proc freq data=&LN..new_pt ORDER = DATA;
   tables TR*age / nocum;
   title '���������� �������';
   format TR TR_f. age age_group_f.;
run;

proc freq data=&LN..new_pt ORDER = DATA;
   tables FRint*age / nocum;
   title '���������� �� �� �����';
   format age age_group_f.;
run;
/**/
/*proc freq data=&LN..LM ORDER = DATA;*/
/*   tables TR / nocum;*/
/*   title '���������� ������� (��������)';*/
/*   format TR TR_f.;*/
/*run;*/
/**/
/*proc freq data=&LN..NLM ORDER = DATA;*/
/*   tables TR / nocum;*/
/*   title '���������� (��������)';*/
/*   format TR TR_f.;*/
/*run;*/
/**/
/*proc freq data=&LN..NLM ORDER = DATA;*/
/*   tables onT / nocum;*/
/*   title '���������� (��������) �� �������';*/
/*   format TR TR_f.;*/
/*run;*/

proc freq data=&LN..new_pt ;
   tables TR*age/ nocum;
   title '���������� ������������ �������';
   format age age_group_f. TR TR_f.;
run;

proc freq data=&LN..vr_pt ;
   tables  d_ch*new_group_riskname/ nocum;
   title '����� �� ������������ �� ������� ����� (����������� ������)';
   format d_ch y_n.;
run;

proc freq data=&LN..vr_pt ;
   tables  d_ch*age/ nocum;
   title '����� �� ������������ �� ���������� ������� (����������� ������)';
   format age age_group_f. d_ch y_n.;
run;

proc freq data=&LN..vr_pt ;
   tables  new_group_riskname*age/ nocum;
   title '������ ����� �� ���������� ������� (����������� ������)';
   format age age_group_f.;
run;



/*-----------------------------------------------------------------------------------------------------------*/
/*-----------------------------------------------------------------------------------------------------------*/
/*---------------------------------------------- ������ ������������ ----------------------------------------*/
/*-----------------------------------------------------------------------------------------------------------*/
/*-----------------------------------------------------------------------------------------------------------*/


%eventan (&LN..new_pt, TLive, i_death, 0,,&y,age,age_group_f.,"������������� �� ��������. ������������");
%eventan (&LN..new_pt, TRF, iRF, 0,,&y,age,age_group_f.,"������������� �� ��������. ������������� ������������");
%eventan (&LN..new_pt, Trel, i_rel, 0,F,&y,age,age_group_f.,"������������� �� ��������. ����������� �������� ��������"); *����������� �������� ��������;



%eventan (boll, TRF, iRF, 0,,&y,new_normkariotip,yn_e.,"B-oll. ������������� �� ���������. ������������� ������������");


/*-----------------------------------------------------------------------------------------------------------*/
/*-----------------------------------------------------------------------------------------------------------*/
/*------------------------------------------ ���������������� ������ ----------------------------------------*/
/*-----------------------------------------------------------------------------------------------------------*/
/*-----------------------------------------------------------------------------------------------------------*/


/*proc sgpanel data=sashelp.class;*/
/* panelby sex /*/
/*    uniscale=row;*/
/* histogram height;*/
/*run;*/

/*6.  ���������������� ������ (�������� ��� �-���, �-���, � ����� ��� ����*/
/*������):*/
/**/
/*�. ���������� ������ �������� � ������ � ������ ��������(���������, ������� ���� �������� � ������:*/

/*- ���, new_gendercode */
/*- �������, age age_group_f.*/
/*- �������������, oll_class*/
/*- ������ �����, new_group_risk*/
/*- ����� ���������� ��� �-��� 30 ��� � �����, ��� �-��� 100 ��� � �����, l_b*/
/*- ����� ����������� - ???, */
/*- ��������� ����� 120, creatinine_b*/
/*- ��������� ����� 30, bilirubin_b*/
/*- �������� ����� 35, albumin_b */
/*- ����� �� ������������, d_ch*/
/*- ���������� �������� ��� ����������, new_normkariotip*/
/*- ��� ����� 750 ldh_b*/


/*��� ����� ���� ������������ proc logistic*/



/*�. ����� ������������ */
/*- ���, ������� (�� 30 � � 30 � ������), new_gendercode age age_group_f.;*/
/*- �������������, oll_class*/
/*- ������ �����, new_group_risk*/
/*- ��� ����� 750, ldh_b*/
/*- ����� ���������� ��� �-��� 30 ��� � �����, ��� �-��� 100 ��� � �����, l_b*/
/*- ���������� �������� ��� ����������, new_normkariotip*/

/*- ����� �� ������������, d_ch*/
/*- ���������� �������� ����� 1 (������� ��������) ��� 2-� ���� �������, FRint*/
/*- ���������� ������������ ���, - ���������� ���������� ��� tkm_au_al*/


/*�. ������������� ������������ */
/*- ���, new_gendercode*/
/*- ������� (�� 30 � � 30 � ������),  age age_group_f.;*/
/*- �������������, oll_class*/
/*- ������ �����, new_group_risk*/
/*- ��� ����� 750, ldh_b*/
/*- ����� ���������� ��� �-��� 30 ��� � �����, ��� �-��� 100 ��� � �����, l_b*/
/*- ���������� �������� ��� ����������, new_normkariotip*/

/*- ����� �� ������������, d_ch*/
/*- ���������� �������� ����� 1 (������� ��������) ��� 2-� ���� �������, FRint*/
/*- ������ ������ �-������������, Laspot*/
/*- ���������� ������������ ���, tkm_au_al*/
/*- ���������� ���������� ��� ------*/


/*proc phreg data=a; 
	model �����*���������_��������������(0)= ������1 ������2; 
run; */

/*��� b-oll*/

/*���������� ������ �������� TR=0 � ������ � ������ �������� TR=2*/

proc logistic data=&LN..boll;
   model i_rem(event='1')= new_gendercode age oll_class new_group_risk l_b creatinine_b bilirubin_b albumin_b d_ch new_normkariotip ldh_b
                / selection=stepwise
                  slentry=0.3
                  slstay=0.1
                  details;
	title "B-oll. ���������� ������ ��������";
	format age age_group_f.;
run;

proc logistic data=&LN..boll;
   model i_ind_death(event='1')= new_gendercode age oll_class new_group_risk l_b creatinine_b bilirubin_b albumin_b d_ch new_normkariotip ldh_b
                / selection=stepwise
                  slentry=0.3
                  slstay=0.1
                  details;
	title "B-oll. ������� � ��������";
run;

proc phreg data=&LN..boll; 
	model TLive*i_death(0)= new_gendercode age oll_class new_group_risk ldh_b l_b new_normkariotip  
/ selection = stepwise slentry = .3 slstay = .15 details;  
	title "B-oll. ���������������� ������. ����� ������������";
	format age age_group_f.;
run; 

/*d_ch FRint tkm_au_al*/

proc phreg data=&LN..boll; 
	model TRF*iRF(0)= new_gendercode age oll_class new_group_risk ldh_b l_b new_normkariotip 
	/ selection = s slentry = .3 slstay = .15;  
	title "B-oll. ���������������� ������. ������������� ������������";
	format age age_group_f.;
run; 
/*d_ch  FRint tkm_au_al Laspot*/







proc logistic data=&LN..toll;
   model i_rem(event='1')= new_gendercode age oll_class new_group_risk l_b creatinine_b bilirubin_b albumin_b d_ch new_normkariotip ldh_b
                / selection=stepwise
                  slentry=0.3
                  slstay=0.1
                  details;
	title "T-oll. ���������� ������ ��������";
	format age age_group_f.;
run;

proc logistic data=&LN..toll;
   model i_ind_death(event='1')= new_gendercode age oll_class new_group_risk l_b creatinine_b bilirubin_b albumin_b d_ch new_normkariotip ldh_b
                / selection=stepwise
                  slentry=0.3
                  slstay=0.1
                  details;
	title "T-oll. ������� � ��������";
run;

proc phreg data=&LN..toll; 
	model TLive*i_death(0)= new_gendercode age oll_class new_group_risk ldh_b l_b new_normkariotip  
/ selection = stepwise slentry = .3 slstay = .15 details;  
	title "T-oll. ���������������� ������. ����� ������������";
	format age age_group_f.;
run; 

proc phreg data=&LN..toll; 
	model TRF*iRF(0)= new_gendercode age oll_class new_group_risk ldh_b l_b new_normkariotip 
	/ selection = s slentry = .3 slstay = .15;  
	title "T-oll. ���������������� ������. ������������� ������������";
	format age age_group_f.;
run; 


proc freq data = &LN..new_pt;
	table (new_gendercode age oll_class new_group_risk l_b creatinine_b bilirubin_b albumin_b d_ch new_normkariotip ldh_b)*i_rem /
	chisq relrisk nopercent nocol;
	format age age_group_f.;
run;

proc freq data = &LN..new_pt;
	table i_rem ;
run;

/*proc freq data = &LN..new_pt;*/
/*	table  age *i_rem /*/
/*	chisq relrisk nopercent nocol;*/
/*	format age triple_age_f.;*/
/*run;*/

/*proc freq data = &LN..new_pt;*/
/*	table  age *i_rem /*/
/*	chisq relrisk nopercent nocol;*/
/*	format age age_group_f.;*/
/*run;*/

*;
proc logistic data=&LN..new_pt plots(only)=roc(id=obs);
class new_gendercode  oll_class new_group_risk l_b creatinine_b bilirubin_b albumin_b d_ch new_normkariotip ldh_b; *age;
   model i_rem(event='1')=albumin_b new_gendercode  oll_class new_group_risk l_b creatinine_b bilirubin_b albumin_b d_ch new_normkariotip ldh_b
                / selection=stepwise
                  slentry=0.3
                  slstay=0.15
                  details;
	title "���������� ������ ��������";
/*	format age age_group_f.;*/
	oddsratio new_gendercode;
	oddsratio oll_class;
	oddsratio new_group_risk; 
	oddsratio l_b; 
	oddsratio creatinine_b;
	oddsratio bilirubin_b;
	oddsratio albumin_b;
	oddsratio d_ch;
	oddsratio new_normkariotip;
	oddsratio ldh_b;
	effectplot;
run;

proc freq data = &LN..new_pt;
	table (new_gendercode ageg oll_class new_group_risk l_b creatinine_b bilirubin_b albumin_b d_ch new_normkariotip ldh_b)*i_ind_death /
	chisq relrisk nopercent nocol;
	format age age_group_f.;
run;

proc freq data = &LN..new_pt;
	table ( ageg  new_normkariotip )*i_ind_death /
	chisq relrisk nopercent nocol;
run;
/*new_gendercode oll_class new_group_risk l_b bilirubin_b albumin_b d_ch  ldh_b new_normkariotip*/




proc logistic data=&LN..new_pt plots(only)=roc(id=obs);
class new_gendercode ageg oll_class new_group_risk l_b creatinine_b bilirubin_b albumin_b d_ch new_normkariotip ldh_b; *age;
   model i_ind_death(event='1')=  ageg new_normkariotip 
                / selection=stepwise
                  slentry=0.5
                  slstay=0.2
                  details;
	title "������� � ��������";
/*	format age age_group_f.;*/
	oddsratio new_gendercode;
	oddsratio oll_class;
	oddsratio ageg;
	oddsratio new_group_risk; 
	oddsratio l_b; 
	oddsratio creatinine_b;
	oddsratio bilirubin_b;
	oddsratio albumin_b;
	oddsratio d_ch;
	oddsratio new_normkariotip;
	oddsratio ldh_b;
	effectplot;
run;


data &LN..DK_pt;
	set &LN..new_pt;
	if new_normkariotip = 0;
run;

proc logistic data=&LN..DK_pt plots(only)=roc(id=obs);
class new_gendercode ageg oll_class new_group_risk l_b creatinine_b bilirubin_b albumin_b d_ch ldh_b; *age;
   model i_ind_death(event='1')= new_gendercode ageg oll_class new_group_risk l_b creatinine_b bilirubin_b albumin_b d_ch new_normkariotip ldh_b
                / selection=stepwise
                  slentry=0.3
                  slstay=0.1
                  details;
	title "������� � ��������";
/*	format age age_group_f.;*/
	oddsratio new_gendercode;
	oddsratio oll_class;
	oddsratio ageg;
	oddsratio new_group_risk; 
	oddsratio l_b; 
	oddsratio creatinine_b;
	oddsratio bilirubin_b;
	oddsratio albumin_b;
	oddsratio d_ch;

	oddsratio ldh_b;
	effectplot;
run;

proc freq data = &LN..new_pt;
	table i_death*new_normkariotip /
	chisq relrisk nopercent nocol;
run;

%eventan (&LN..new_pt, TLive, i_death, 0,,&y,new_normkariotip,yn_e.," ������������� �� ���������. ������������� ������������");

data &LN..NED_pt;
	set &LN..new_pt;
	if i_ind_death = 0;
run;
%eventan (&LN..NED_pt, TLive, i_death, 0,,&y,new_normkariotip,yn_e.," ������������� �� ���������. ������������� ������������");

proc sort  data=&LN..new_pt;
	by oll_class;
run;

proc phreg data=&LN..new_pt;
	by oll_class;
	model TLive*i_death(0)= new_gendercode age new_group_risk ldh_b l_b 
/ selection = stepwise slentry = .3 slstay = .1 details;  
	title "���������������� ������. ����� ������������";
	format age age_group_f. oll_class oc_f.;
run; 



proc phreg data=&LN..new_pt;
	by oll_class;
	model TRF*iRF(0)= new_gendercode age new_group_risk ldh_b l_b reg tkm_au_al
	/ selection = s slentry = .3 slstay = .1;  
	title "���������������� ������. ������������� ������������";
	format age age_group_f.  oll_class oc_f.;
run; 


proc freq data = &LN..new_pt;
	table i_rem*i_ind_death /
	chisq relrisk nopercent nocol;
run;

%eventan (&LN..boll, TLive, i_death, 0,,&y,new_normkariotip,yn_e.,"B-oll. ������������� �� ���������. ����� ������������");
%eventan (&LN..boll, Trel, i_rel, 0,F,&y,new_normkariotip,yn_e.,"B-oll. ������������� �� ���������. ����������� �������� ��������"); *����������� �������� ��������;

%eventan (&LN..boll, TLive, i_death, 0,,&y,age,age_group_f.,"B-oll. ������������� �� ��������. ����� ������������");
%eventan (&LN..boll, TRF, iRF, 0,,&y,age,age_group_f.,"B-oll. ������������� �� ��������. ������������� ������������");

%eventan (&LN..toll, TLive, i_death, 0,,&y,age,age_group_f.,"T-oll. ������������� �� ��������. ����� ������������");
%eventan (&LN..toll, TRF, iRF, 0,,&y,age,age_group_f.,"T-oll. ������������� �� ��������. ������������� ������������");


data t;
	set &LN..toll;
	if vr = 1;
run;

proc freq data = t;
	table new_uvsredostenname/ nocum;
	title "T-oll (������������� ������� ������)";
run;

proc freq data = t;
	table
new_neyrolekname/ nocum;
run;


proc freq data = t;
	table
new_normkariotipname/ nocum;
run;

proc freq data = t;
	table
new_citogenname / nocum;
run;


data &LN..tmp;
    set &LN..new_pt;
	if date_tkm<date_rel then output;
	if i_rel = 0 then output;
run;

proc freq data = &LN..tmp;
	table age*tkm_au_al /
	chisq relrisk nopercent nocol;
  	title '';
	format age age_group_f. tkm_au_al au_al_f.;
run;
