create table if not exists seasons
(
	year		int primary key,
	url 		varchar(500)
); 


create table if not exists status
(
	statusId	int primary key,	
	status 		varchar(200)
); 


create table if not exists circuits
(
	circuitid		int primary key,
	circuitref		varchar(500),
	name			varchar(500),
	location		varchar(500),
	country			varchar(500),
	latitude		decimal,
	longitude		decimal,
	altitude		int,
	url				varchar(500)
);


create table if not exists races
(
	raceId			int primary key,
	year			int references seasons(year),
	round			int,
	circuitId		int references circuits(circuitid),
	name			varchar(500),
	date			date,
	time			time,
	url				varchar(500),
	fp1_date		date,
	fp1_time		time,
	fp2_date		date,
	fp2_time		time,
	fp3_date		date,
	fp3_time		time,
	quali_date		date,
	quali_time		time,
	sprint_date		date,
	sprint_time		time
); 


create table if not exists drivers
(
	driverId		int primary key,
	driverRef		varchar(500),
	number			int,
	code			varchar(500),
	forename		varchar(500),
	surname			varchar(500),
	dob				date,
	nationality		varchar(500),
	url				varchar(500)
);


create table if not exists constructors
(
	constructorId		int primary key,
	constructorRef		varchar(500),
	name				varchar(500),
	nationality			varchar(500),
	url					varchar(500)
);


create table if not exists constructor_results
(
	constructorResultsId		int primary key,
	raceId						int references races(raceid),
	constructorId				int references constructors(constructorId),
	points						decimal,
	status						varchar(20)
);


create table if not exists constructor_standings
(
	
	constructorStandingsId		int primary key,
	raceId						int references races(raceid),
	constructorId				int references constructors(constructorId),
	points						decimal,
	position					int,
	positionText				varchar(100),
	wins						int
);


create table if not exists driver_standings
(
	
	driverStandingsId		int primary key,
	raceId					int references races(raceid),
	driverId				int references drivers(driverId),
	points					decimal,
	position				int,
	positionText			varchar(100),
	wins					int
);


create table if not exists lap_times
(
	raceId			int references races(raceid),
	driverId		int references drivers(driverId),
	lap				int,
	position		int,
	time			time,
	milliseconds	int
);

create index if not exists idx01_lap_times on lap_times(raceId,driverId);


create table if not exists pit_stops
(
	
	raceId				int references races(raceid),
	driverId			int references drivers(driverId),
	stop				int,
	lap					int,
	time				time,
	duration			interval,
	milliseconds		int
);


create table if not exists qualifying
(
	qualifyId			int primary key,
	raceId				int references races(raceid),
	driverId			int references drivers(driverId),
	constructorId		int references constructors(constructorId),
	number				int,
	position			int,
	q1					time,
	q2					time,
	q3					time
); 



create table if not exists results
(
	
	resultId			int primary key,
	raceId				int references races(raceid),
	driverId			int references drivers(driverId),
	constructorId		int references constructors(constructorId),
	number				int,
	grid				int,
	position			int,
	positionText		varchar(100),
	positionOrder		int,
	points				decimal,
	laps				int,
	time				varchar(30),
	milliseconds		int,
	fastestLap			int,
	rank				int,
	fastestLapTime		time,
	fastestLapSpeed		decimal ,
	statusId			int references status(statusId)
); 



create table if not exists sprint_results
(
	resultId			int primary key,
	raceId				int references races(raceid),
	driverId			int references drivers(driverId),
	constructorId		int references constructors(constructorId),
	number				int,
	grid				int,
	position			int,
	positionText		varchar(100),
	positionOrder		int,
	points				decimal,
	laps				int,
	time				varchar(100),
	milliseconds		int,
	fastestLap			int,
	fastestLapTime		time,
	statusId			int references status(statusId)
); 





