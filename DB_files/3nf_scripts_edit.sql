-- Table Creation
create table card(
	card_id_1 varchar(20),
	card_id_2 int unique,
	balance decimal(13,2),
	exp_date date ,
	primary key(card_id_1,card_id_2)
);

 create table card_status(
    card_id_1 varchar(20),
	card_id_2 int unique,
    status bool,
	foreign key(card_id_1,card_id_2) references card(card_id_1,card_id_2) on delete cascade
 );   

create table stations(
	station_name char(50) primary key not null,
	station_class char(10), 
	station_cost decimal(13,2)
);

create table transactions(
	trans_id_1 varchar(20),
	trans_id_2 int unique,
	card_id_1 varchar(20),
	card_id_2 int,
	trans_source char(50),
	trans_destination char(50),
	primary key(trans_id_1,trans_id_2),
	foreign key(card_id_1,card_id_2) references card(card_id_1,card_id_2) on delete cascade
);

create table transaction_cost(
	trans_id_1 varchar(20),
	trans_id_2 int unique,
	trans_cost decimal(13,2),
	foreign key (trans_id_1, trans_id_2) references transactions(trans_id_1, trans_id_2) on delete cascade
);

-- MISC.
-- delete from card;
-- delete from transactions;

select * from transactions
where concat(card_id_1,card_id_2) = 'MTROCRD26122021-5';

-- DB initialization
insert into card values('MTROCRD26122021-',1,50.0,date(now()+ interval '1 year'));
insert into card_status values('MTROCRD26122021-',1, true);

insert into transactions values('TRANS26122021-',1,'MTROCRD26122021-',1,'None','None');
insert into transaction_cost values ('TRANS26122021-',1, 50.0);



select insert_to_card();
select * from card;
select * from transactions;

-- delete from card where card_id_2 = 13;

-- initialization of stations table
insert into stations values('Baiyappanahalli','A',28.65);
insert into stations values('Swami-Vivekananda-Road','A',25.05);
insert into stations values('Indiranagar','A',22.55);
insert into stations values('Halasuru','A',18.25);
insert into stations values('Trinity','A',15.4);
insert into stations values('Mahatma-Gandhi-Road','A',11.2);
insert into stations values('Cubbon-Park','A',9.6);
insert into stations values('Dr.B.R.Ambedkar-Stn.','A',6.7);
insert into stations values('Sir-M-Visveswaraya-Station','A',2.8);
insert into stations values('Nadaprabhu-Kempegowda-Station','center',0);
insert into stations values('Sangolli-Rayanna-Station','B',3.8);
insert into stations values('Magadi-Road','B',7.05);
insert into stations values('Vijayanagar','B',10.15);
insert into stations values('Athiguppe','B',14.15);
insert into stations values('Deepanjali-Nagar','B',18.05);
insert into stations values('Mysore-Road','B',20.80);
insert into stations values('Chikpete','C', 3.2);
insert into stations values('Krishna-Rajendra-Market','C', 5.3);
insert into stations values('National-College','C', 9.1);
insert into stations values('Lalbagh','C', 12.45);
insert into stations values('Southend-Circle','C', 15.65);
insert into stations values('Jayanagar','C', 18.85);
insert into stations values('Rashtriya-Vidyalaya-Road','C', 22.65);
insert into stations values('Banashankari','C', 25.85);
insert into stations values('Jayapraksh-Nagar','C', 28.7);
insert into stations values('Yelachenahalli','C', 30.1);
insert into stations values('Mantri-Square-Sampige-Road','D', 3.25);
insert into stations values('Srirampura','D', 5.75);
insert into stations values('Mahakavi-Kuvempu-Road','D', 8.25);
insert into stations values('Rajajinagar','D', 11);
insert into stations values('Mahalakshmi-layout','D', 13.1);
insert into stations values('Sandal-Soap-Factory','D', 15.15);
insert into stations values('Yeshwanthpur','D', 18.90);
insert into stations values('Goraguntepalya','D', 20);
insert into stations values('Peenya','D', 23.2);
insert into stations values('Peenya-Industry','D', 26.65);
insert into stations values('Jalahalli','D', 28.75);
insert into stations values('Dasarahalli','D', 30.25);
insert into stations values('Nagasandra','D', 31.95);

select * from card;

-- Function to insert a new card to DB and add the same to the transaction table
create or replace function insert_to_card()
	returns varchar
	language plpgsql
	as
$$
begin 
		insert into card 
		select concat('MTROCRD',to_char(NOW() :: DATE, 'ddmmyyyy-')),max(card_id_2)+1,0,date(now()+ interval '1 year') from card;
		insert into card_status 
		select concat('MTROCRD',to_char(NOW() :: DATE, 'ddmmyyyy-')),max(card_id_2)+1, true from card_status;
		
		insert into transactions
		select concat('TRANS',to_char(NOW() :: DATE, 'ddmmyyyy-')),max(trans_id_2)+1,concat('MTROCRD',to_char(NOW() :: DATE, 'ddmmyyyy-')),max(c_.card_id_2),null,null from transactions t_, card c_;
		insert into transaction_cost
		select concat('TRANS',to_char(NOW() :: DATE, 'ddmmyyyy-')),max(trans_id_2)+1, 50.0 from transaction_cost;
		
		return concat(concat('MTROCRD',to_char(NOW() :: DATE, 'ddmmyyyy-')),max(card_id_2)) from card;
end;
$$

-- trigger function insert 50rs
create or replace function update_bal()
	returns trigger
	language plpgsql
as $$
begin
	new.balance = 50;
	return new;
end;
$$

-- trigger to insert 50rs balance to cards after insertion

create or replace trigger update_balance
before insert
on card
for each row
execute procedure update_bal();

--Testing if trigger works
delete from card where card_id_2 = 22;
select * from card;
select * from transactions;
select insert_to_card();

-- select date(now()+interval '1 year');

select recharge(200,'MTROCRD11012022-',6);
select * from transactions;

-- Function to recharge a card and add the same to the transaction table
create or replace function recharge(amount decimal(13,2),cardNo1 varchar,cardNo2 int)
	returns decimal(13,2)
	language plpgsql
	as
$$
begin
		update card
		set balance = balance + amount
		where cardNo2 = card_id_2;
		
		call recharge_push(cardNo1, cardNo2, amount);
		
		return (select balance from card where cardNo2 = card_id_2);
		
end;
$$

--stored procedure to push the recharge details to transaction table

create or replace procedure recharge_push(cardNo1 varchar, cardNo2 int, amount decimal(13,2))
language plpgsql
as $$
begin
		
		insert into transactions
		select concat('TRANS',to_char(NOW() :: DATE, 'ddmmyyyy-')),max(trans_id_2)+1,cardNo1,cardNo2,null,null from transactions t_, card c_;
		
		insert into transaction_cost
		select concat('TRANS',to_char(NOW() :: DATE, 'ddmmyyyy-')),max(trans_id_2)+1, amount from transaction_cost;
end;
$$

--test the recharge function with stored procedure
select * from card;
select * from transactions;
select recharge(200,'MTROCRD26122021-',4);


-- Function to just get the cost of a travel
create or replace function travel(cardNo1 varchar,cardNo2 int, source_ char, dest_ char)
	returns decimal(13,2)
	language plpgsql
	as
$$
declare
	cost1 decimal(13,2);
	cost2 decimal(13,2);
	class1 char(20);
	class2 char(20);
	
begin
		select stations.station_cost into cost1 from stations where station_name = source_;
		select stations.station_class into class1 from stations where station_name = source_;
		select stations.station_cost into cost2 from stations where station_name = dest_;
		select stations.station_class into class2 from stations where station_name = dest_;
		if class1 = 'center' then
			return cost2;
		elsif class2 = 'center' then
			return cost1;
		elsif class1 = class2 then
			return abs(cost1-cost2);
		elsif class1 <> class2 then
			return cost2+cost1;
		else
			return -1;
		end if;
end
$$

select * from card;

select travel('MTROCRD26122021-',4,'Mahalakshmi-layout', 'Nadaprabhu-Kempegowda-Station');

-- Function to update the balance after travel and push the same to transaction table
create or replace function update_balance(amount decimal(13,2),cardNo1 varchar,cardNo2 int,  source_ char(50), dest_ char(50))
	returns Numeric(13,2)
	language plpgsql
	as
$$
begin
		update card
		set balance = balance - amount
		where cardNo2 = card_id_2;
		
		insert into transactions
		select concat('TRANS',to_char(NOW() :: DATE, 'ddmmyyyy-')),max(trans_id_2)+1,cardNo1,cardNo2,source_,dest_ from transactions t_, card c_;
		insert into transaction_cost
		select concat('TRANS',to_char(NOW() :: DATE, 'ddmmyyyy-')),max(trans_id_2)+1, amount from transaction_cost;
		
		return (select balance from card where cardNo2 = card_id_2);
		
end;
$$

select update_balance(100,'MTROCRD11012022-',6,'Mahalakshmi layout', 'Nadaprabhu Kempegowda Station');
select * from transaction_cost;

-- function to retreive the balance of a card
create or replace function ret_bal(cardNo1 varchar, cardNo2 int)
	returns Numeric(13,2)
	language plpgsql
	as
	$$
begin 
	return (select balance from card where card_id_2 = cardNo2);
	
end;
$$

select ret_bal('MTROCRD11012022-', 6);
select * from card;

update card set balance = 40 where card_id_2 = 26;
	
