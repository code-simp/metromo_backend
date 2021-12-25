-- Database: metromo

-- DROP DATABASE IF EXISTS metromo;

CREATE DATABASE metromo
    WITH 
    OWNER = postgres
    ENCODING = 'UTF8'
    LC_COLLATE = 'C'
    LC_CTYPE = 'C'
    TABLESPACE = pg_default
    CONNECTION LIMIT = -1;

COMMENT ON DATABASE metromo
    IS 'first try for mteromo database';
	
-- Table Creation
create table card(
	card_id_1 varchar(20),
	card_id_2 int unique,
	balance decimal(13,2),
	status bool,
	exp_date date,
	primary key(card_id_1,card_id_2)
	);
	
create table stations(
	station_name char(50) primary key not null,
	stattion_cost decimal(13,2)
);

create table transactions(
	trans_id_1 varchar(20),
	trans_id_2 int unique,
	card_id_1 varchar(20),
	card_id_2 int,
	trans_cost decimal(13,2),
	trans_source char(20),
	trans_destination char(20),
	primary key(trans_id_1,trans_id_2),
	foreign key(card_id_1,card_id_2) references card(card_id_1,card_id_2) on delete cascade
);

-- MISC.
-- delete from card;
-- delete from transactions;

-- DB initialization
insert into card values('MTROCRD26122021-',1,50.0,true,date(now()+ interval '1 year'));
insert into transactions values('TRANS26122021-',1,'MTROCRD26122021-',1,50.0,null,null);

select insert_to_card();
select * from card;
select * from transactions;



-- initialization of stations table
insert into stations values('Baiyappanahalli',0.00);
insert into stations values('Swami Vivekananda Road',9.5);
insert into stations values('Indiranagar',14.25);
insert into stations values('Halasuru',14.25);
insert into stations values('Trinity',17.1);
insert into stations values('Mahatma Gandhi Road',19);
insert into stations values('Cubbon Park',20.9);
insert into stations values('Dr.B.R.Ambedkar Stn.',23.75);
insert into stations values('Sir M Visveswaraya Station',26.6);
insert into stations values('Nadaprabhu Kempegowda Station',28.5);
insert into stations values('Magadi Road',33.25);
insert into stations values('Vijayanagar',36.1);
insert into stations values('Athiguppe',38);
insert into stations values('Deepanjali Nagar',39.9);
insert into stations values('Mysore Road',42.75);
insert into stations values('Chikpete', 30.2);
insert into stations values('Krishna Rajendra Market', 32.1);
insert into stations values('National College', 33.8);
insert into stations values('Lalbagh', 36.35);
insert into stations values('Southend Circle', 39.2);
insert into stations values('Jayanagar', 39.2);
insert into stations values('Rashtriya Vidyalaya Road', 43.8);
insert into stations values('Banashankari', 46.25);
insert into stations values('Jayapraksh nagar', 49.7);
insert into stations values('Yelachenahalli', 52.1);
insert into stations values('Mantri Square Sampige Road', 31.25);
insert into stations values('Srirampura', 32.5);
insert into stations values('Mahakavi Kuvempu road', 37.5);
insert into stations values('Rajajinagar', 39.75);
insert into stations values('Mahalakshmi layout', 42.1);
insert into stations values('Sandal Soap Factory', 46.15);
insert into stations values('Yeshwanthpur', 49.90);
insert into stations values('Goraguntepalya', 51.1);
insert into stations values('Peenya', 53.2);
insert into stations values('Peenya Industry', 56.45);
insert into stations values('Jalahalli', 57.75);
insert into stations values('Dasarahalli', 61.25);
insert into stations values('Nagasandra', 67.95);

-- Function to insert a new card to DB and add the same to the transaction table
create or replace function insert_to_card()
	returns void
	language plpgsql
	as
$$
begin 
		insert into card 
		select concat('MTROCRD',to_char(NOW() :: DATE, 'ddmmyyyy-')),max(card_id_2)+1,50,true,date(now()+ interval '1 year') from card; 

		insert into transactions
		select concat('TRANS',to_char(NOW() :: DATE, 'ddmmyyyy-')),max(trans_id_2)+1,concat('MTROCRD',to_char(NOW() :: DATE, 'ddmmyyyy-')),max(c_.card_id_2),50.0,null,null from transactions t_, card c_;

end;
$$

-- select date(now()+interval '1 year');

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
		
		insert into transactions
		select concat('TRANS',to_char(NOW() :: DATE, 'ddmmyyyy-')),max(trans_id_2)+1,cardNo1,cardNo2,amount,null,null from transactions t_, card c_;
		
		return (select balance from card where cardNo2 = card_id_2);
		
end;
$$














