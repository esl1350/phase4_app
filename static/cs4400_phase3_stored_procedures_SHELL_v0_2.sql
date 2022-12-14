-- CS4400: Introduction to Database Systems (Fall 2022)
-- Project Phase III: Stored Procedures SHELL [v0] Monday, Oct 31, 2022
set global transaction isolation level serializable;
set global SQL_MODE = 'ANSI,TRADITIONAL';
set names utf8mb4;
set SQL_SAFE_UPDATES = 0;

use restaurant_supply_express;
-- -----------------------------------------------------------------------------
-- stored procedures and views
-- -----------------------------------------------------------------------------
/* Standard Procedure: If one or more of the necessary conditions for a procedure to
be executed is false, then simply have the procedure halt execution without changing
the database state. Do NOT display any error messages, etc. */

-- [1] add_owner()
-- -----------------------------------------------------------------------------
/* This stored procedure creates a new owner.  A new owner must have a unique
username.  Also, the new owner is not allowed to be an employee. */
-- -----------------------------------------------------------------------------
drop procedure if exists add_owner;
delimiter //
create procedure add_owner (in ip_username varchar(40), in ip_first_name varchar(100),
	in ip_last_name varchar(100), in ip_address varchar(500), in ip_birthdate date)
sp_main: begin
	if isnull(ip_username) then leave sp_main; end if;
    if isnull(ip_first_name) then leave sp_main; end if;
    if isnull(ip_last_name) then leave sp_main; end if;
    if isnull(ip_address) then leave sp_main; end if;
    if isnull(ip_birthdate) then leave sp_main; end if;
    if (select count(*) from employees where username = ip_username) > 0
		then leave sp_main; end if;
	if (select count(*) from restaurant_owners where username = ip_username) > 0
		then leave sp_main; end if;
    insert into users values(ip_username, ip_first_name, ip_last_name, ip_address, ip_birthdate);
    insert into restaurant_owners values(ip_username);
end //
delimiter ;

-- [2] add_employee()
-- -----------------------------------------------------------------------------
/* This stored procedure creates a new employee without any designated pilot or
worker roles.  A new employee must have a unique username unique tax identifier. */
-- -----------------------------------------------------------------------------
drop procedure if exists add_employee;
delimiter //
create procedure add_employee (in ip_username varchar(40), in ip_first_name varchar(100),
	in ip_last_name varchar(100), in ip_address varchar(500), in ip_birthdate date,
    in ip_taxID varchar(40), in ip_hired date, in ip_employee_experience integer,
    in ip_salary integer)
sp_main: begin
	if isnull(ip_username) then leave sp_main; end if;
    if isnull(ip_first_name) then leave sp_main; end if;
    if isnull(ip_last_name) then leave sp_main; end if;
    if isnull(ip_address) then leave sp_main; end if;
    if isnull(ip_birthdate) then leave sp_main; end if;
    if isnull(ip_taxID) then leave sp_main; end if;
    if isnull(ip_hired) then leave sp_main; end if;
    if isnull(ip_employee_experience) then leave sp_main; end if;
    if isnull(ip_salary) then leave sp_main; end if;
    -- ensure new owner has a unique username
    if (select count(*) from employees where username = ip_username) > 0
		then leave sp_main; end if;
    -- ensure new employee has a unique tax identifier
    if (select count(*) from employees where taxID = ip_taxID) > 0
		then leave sp_main; end if;
	if ip_birthdate >= ip_hired then leave sp_main; end if;
	insert into users values(ip_username, ip_first_name, ip_last_name, ip_address, ip_birthdate);
    insert into employees values(ip_username, ip_taxID, ip_hired, ip_employee_experience, ip_salary);
end //
delimiter ;

-- [3] add_pilot_role()
-- -----------------------------------------------------------------------------
/* This stored procedure adds the pilot role to an existing employee.  The
employee/new pilot must have a unique license identifier. */
-- -----------------------------------------------------------------------------
drop procedure if exists add_pilot_role;
delimiter //
create procedure add_pilot_role (in ip_username varchar(40), in ip_licenseID varchar(40),
	in ip_pilot_experience integer)
sp_main: begin
	if isnull(ip_username) then leave sp_main; end if;
    if isnull(ip_licenseID) then leave sp_main; end if;
    if isnull(ip_pilot_experience) then leave sp_main; end if;
    -- ensure new employee exists
    if not exists (select 1 from employees where username = ip_username)
    then leave sp_main;
    end if;
    if (select count(*) from delivery_services where manager = ip_username) > 0 then leave sp_main; end if;
    -- ensure new pilot has a unique license identifier
    if exists (select 1 from pilots where licenseID = ip_licenseID)
    then leave sp_main;
    end if;
    
    insert into pilots values (ip_username, ip_licenseID, ip_pilot_experience);
end //
delimiter ;

-- [4] add_worker_role()
-- -----------------------------------------------------------------------------
/* This stored procedure adds the worker role to an existing employee. */
-- -----------------------------------------------------------------------------
drop procedure if exists add_worker_role;
delimiter //
create procedure add_worker_role (in ip_username varchar(40))
sp_main: begin
	if isnull(ip_username) then leave sp_main; end if;
    -- ensure new employee exists
    if not exists (select 1 from employees where username = ip_username)
    then leave sp_main;
    end if;
    
    insert into workers values (ip_username);
end //
delimiter ;

-- [5] add_ingredient()
-- -----------------------------------------------------------------------------
/* This stored procedure creates a new ingredient.  A new ingredient must have a
unique barcode. */
-- -----------------------------------------------------------------------------
drop procedure if exists add_ingredient;
delimiter //
create procedure add_ingredient (in ip_barcode varchar(40), in ip_iname varchar(100),
	in ip_weight integer)
sp_main: begin
	if isnull(ip_barcode) then leave sp_main; end if;
    if isnull(ip_iname) then leave sp_main; end if;
    if isnull(ip_weight) then leave sp_main; end if;
    if ip_weight <= 0 then leave sp_main; end if;
	-- ensure new ingredient doesn't already exist
	if (ip_barcode in (select barcode from ingredients)) then leave sp_main; end if;
    insert into ingredients values (ip_barcode, ip_iname, ip_weight);
end //
delimiter ;

-- [6] add_drone()
-- -----------------------------------------------------------------------------
/* This stored procedure creates a new drone.  A new drone must be assigned 
to a valid delivery service and must have a unique tag.  Also, it must be flown
by a valid pilot initially (i.e., pilot works for the same service), but the pilot
can switch the drone to working as part of a swarm later. And the drone's starting
location will always be the delivery service's home base by default. */
-- -----------------------------------------------------------------------------
drop procedure if exists add_drone;
delimiter //
create procedure add_drone (in ip_id varchar(40), in ip_tag integer, in ip_fuel integer,
	in ip_capacity integer, in ip_sales integer, in ip_flown_by varchar(40))
sp_main: begin
	if isnull(ip_id) then leave sp_main; end if;
    if isnull(ip_tag) then leave sp_main; end if;
    if isnull(ip_fuel) then leave sp_main; end if;
    if isnull(ip_capacity) then leave sp_main; end if;
    if isnull(ip_sales) then leave sp_main; end if;
    if isnull(ip_flown_by) then leave sp_main; end if;
	-- ensure new drone doesn't already exist
	if (select count(*) from drones where id = ip_id and tag = ip_tag > 0) then leave sp_main; end if;
    -- ensure that the delivery service exists
	if (ip_id not in (select id from delivery_services)) then leave sp_main; end if;
    -- ensure that a valid pilot will control the drone
    if (ip_flown_by not in (select username from pilots)) then leave sp_main; end if;
    if ((select id from work_for where username = ip_flown_by) != ip_id or (select count(*) from pilots where username = ip_flown_by) <= 0) then leave sp_main; end if;
    if ip_fuel <= 0 or ip_capacity < 0 or ip_sales < 0 then leave sp_main; end if;
    if (select space from locations where label = (select home_base from delivery_services where ip_id = id)) <= 0 then leave sp_main; end if;
    set @home = (select home_base from delivery_services where ip_id = id);
    insert into drones values (ip_id, ip_tag, ip_fuel, ip_capacity, ip_sales, ip_flown_by, null, null, @home);
    update locations set space = space - 1 where label = (select home_base from delivery_services where ip_id = id);
end //
delimiter ;

-- [7] add_restaurant()
-- -----------------------------------------------------------------------------
/* This stored procedure creates a new restaurant.  A new restaurant must have a
unique (long) name and must exist at a valid location, and have a valid rating.
And a resturant is initially "independent" (i.e., no owner), but will be assigned
an owner later for funding purposes. */
-- -----------------------------------------------------------------------------
drop procedure if exists add_restaurant;
delimiter //
create procedure add_restaurant (in ip_long_name varchar(40), in ip_rating integer,
	in ip_spent integer, in ip_location varchar(40))
sp_main: begin
	if isnull(ip_long_name) then leave sp_main; end if;
    if isnull(ip_rating) then leave sp_main; end if;
    if isnull(ip_spent) then leave sp_main; end if;
    if isnull(ip_location) then leave sp_main; end if;
    if ip_spent < 0 then leave sp_main; end if;
	-- ensure new restaurant doesn't already exist
	if (ip_long_name in (select long_name from restaurants)) then leave sp_main; end if;
    -- ensure that the location is valid
	if (ip_location not in (select label from locations)) then leave sp_main; end if;
    -- ensure that the rating is valid (i.e., between 1 and 5 inclusively)
    if (ip_rating not between 1 and 5) then leave sp_main; end if;
    insert into restaurants values(ip_long_name, ip_rating, ip_spent, ip_location, null);
end //
delimiter ;

-- [8] add_service()
-- -----------------------------------------------------------------------------
/* This stored procedure creates a new delivery service.  A new service must have
a unique identifier, along with a valid home base and manager. */
-- -----------------------------------------------------------------------------
drop procedure if exists add_service;
delimiter //
create procedure add_service (in ip_id varchar(40), in ip_long_name varchar(100),
	in ip_home_base varchar(40), in ip_manager varchar(40))
sp_main: begin
	if isnull(ip_id) then leave sp_main; end if;
    if isnull(ip_long_name) then leave sp_main; end if;
    if isnull(ip_home_base) then leave sp_main; end if;
    if isnull(ip_manager) then leave sp_main; end if;
	-- ensure new delivery service doesn't already exist
    if (select count(*) from delivery_services where id = ip_id) > 0
		then leave sp_main; end if;
    -- ensure that the home base location is valid
    if not exists (select 1 from restaurants where location = ip_home_base)
        then leave sp_main; end if;
    -- ensure that the manager is valid
    if (ip_manager not in (select username from workers))
        then leave sp_main; end if;
	if (ip_manager in (select manager from delivery_services))
		then leave sp_main; end if;
	if (ip_manager in (select username from work_for))
		then leave sp_main; end if;
    insert into delivery_services values (ip_id, ip_long_name, ip_home_base, ip_manager);
    insert into work_for values (ip_manager, ip_id);
    
end //
delimiter ;
-- [9] add_location()
-- -----------------------------------------------------------------------------
/* This stored procedure creates a new location that becomes a new valid drone
destination.  A new location must have a unique combination of coordinates.  We
could allow for "aliased locations", but this might cause more confusion that
it's worth for our relatively simple system. */
-- -----------------------------------------------------------------------------
drop procedure if exists add_location;
delimiter //
create procedure add_location (in ip_label varchar(40), in ip_x_coord integer,
	in ip_y_coord integer, in ip_space integer)
sp_main: begin
	if isnull(ip_label) then leave sp_main; end if;
    if isnull(ip_x_coord) then leave sp_main; end if;
    if isnull(ip_y_coord) then leave sp_main; end if;
    if isnull(ip_space) then leave sp_main; end if;
	-- ensure new location doesn't already exist
    if (select count(*) from locations where label = ip_label) > 0
		then leave sp_main; end if;
    -- ensure that the coordinate combination is distinct
    if (select count(*) from locations where x_coord = ip_x_coord and y_coord = ip_y_coord group by x_coord, y_coord) > 0
		then leave sp_main; end if;
        
	insert into locations values(ip_label, ip_x_coord, ip_y_coord, ip_space);
end //
delimiter ;

-- [10] start_funding()
-- -----------------------------------------------------------------------------
/* This stored procedure opens a channel for a restaurant owner to provide funds
to a restaurant. If a different owner is already providing funds, then the current
owner is replaced with the new owner.  The owner and restaurant must be valid. */
-- -----------------------------------------------------------------------------
drop procedure if exists start_funding;
delimiter //
create procedure start_funding (in ip_owner varchar(40), in ip_long_name varchar(40))
sp_main: begin
	if isnull(ip_owner) then leave sp_main; end if;
    if isnull(ip_long_name) then leave sp_main; end if;
	-- ensure the owner and restaurant are valid
	if (select count(*) from restaurant_owners where username = ip_owner) = 0
		then leave sp_main; end if;
	if (select count(*) from restaurants where long_name = ip_long_name) = 0
		then leave sp_main; end if;
	update restaurants set funded_by = ip_owner where long_name = ip_long_name;
end //
delimiter ;

-- [11] hire_employee()
-- -----------------------------------------------------------------------------
/* This stored procedure hires an employee to work for a delivery service.
Employees can be combinations of workers and pilots. If an employee is actively
controlling drones or serving as manager for a different service, then they are
not eligible to be hired.  Otherwise, the hiring is permitted. */
-- -----------------------------------------------------------------------------
drop procedure if exists hire_employee;
delimiter //
create procedure hire_employee (in ip_username varchar(40), in ip_id varchar(40))
sp_main: begin
	if isnull(ip_username) then leave sp_main; end if;
    if isnull(ip_id) then leave sp_main; end if;
	-- ensure that the employee hasn't already been hired
    if (select count(*) from work_for where username = ip_username and id = ip_id group by username, id) > 0
		then leave sp_main; end if;
	-- ensure that the employee and delivery service are valid
    if not exists (select 1 from employees where username = ip_username)
		then leave sp_main; end if;
    if not exists (select 1 from delivery_services where id = ip_id)
		then leave sp_main; end if;
    -- ensure that the employee isn't a manager for another service
	if (select count(*) from delivery_services where manager = ip_username and id != ip_id) > 0
		then leave sp_main; end if;
	-- ensure that the employee isn't actively controlling drones for another service
    if (select count(*) from drones where flown_by = ip_username and id != ip_id) > 0
		then leave sp_main; end if;
    
    insert into work_for values(ip_username, ip_id);
end //
delimiter ;
-- [12] fire_employee()
-- -----------------------------------------------------------------------------
/* This stored procedure fires an employee who is currently working for a delivery
service.  The only restrictions are that the employee must not be: [1] actively
controlling one or more drones; or, [2] serving as a manager for the service.
Otherwise, the firing is permitted. */
-- -----------------------------------------------------------------------------
drop procedure if exists fire_employee;
delimiter //
create procedure fire_employee (in ip_username varchar(40), in ip_id varchar(40))
sp_main: begin
	if isnull(ip_username) then leave sp_main; end if;
    if isnull(ip_id) then leave sp_main; end if;
	-- ensure that the employee is currently working for the service
    if (select count(*) from work_for where username = ip_username and id = ip_id) = 0
		then leave sp_main; end if;
    -- ensure that the employee isn't an active manager
    if (select count(*) from delivery_services where manager = ip_username) > 0
		then leave sp_main; end if;
	-- ensure that the employee isn't controlling any drones
    if (select count(*) from drones where flown_by = ip_username) > 0
		then leave sp_main; end if;
        
	delete from work_for where username = ip_username and id = ip_id;
    
end //
delimiter ;

-- [13] manage_service()
-- -----------------------------------------------------------------------------
/* This stored procedure appoints an employee who is currently hired by a delivery
service as the new manager for that service.  The only restrictions are that: [1]
the employee must not be working for any other delivery service; and, [2] the
employee can't be flying drones at the time.  Otherwise, the appointment to manager
is permitted.  The current manager is simply replaced.  And the employee must be
granted the worker role if they don't have it already. */
-- -----------------------------------------------------------------------------
drop procedure if exists manage_service;
delimiter //
create procedure manage_service (in ip_username varchar(40), in ip_id varchar(40))
sp_main: begin
	if isnull(ip_username) then leave sp_main; end if;
    if isnull(ip_id) then leave sp_main; end if;
	-- ensure that the employee is currently working for the service
    if not exists(select 1 from work_for where username = ip_username and id = ip_id group by username, id)
		then leave sp_main; end if;
	-- ensure that the employee is not flying any drones
	if (select count(*) from drones where flown_by = ip_username) > 0
		then leave sp_main; end if;
    -- ensure that the employee isn't working for any other services
    if (select count(id) from work_for where username = ip_username) > 1
		then leave sp_main; end if;
    -- add the worker role if necessary
    if (select count(*) from workers where username = ip_username) < 1
		then leave sp_main; end if;
    
    update delivery_services set manager = ip_username where id = ip_id;
end //
delimiter ;
-- [14] takeover_drone()
-- -----------------------------------------------------------------------------
/* This stored procedure allows a valid pilot to take control of a lead drone owned
by the same delivery service, whether it's a "lone drone" or the leader of a swarm.
The current controller of the drone is simply relieved of those duties. And this
should only be executed if a "leader drone" is selected. */
-- -----------------------------------------------------------------------------
drop procedure if exists takeover_drone;
delimiter //
create procedure takeover_drone (in ip_username varchar(40), in ip_id varchar(40),
	in ip_tag integer)
sp_main: begin
	if isnull(ip_username) then leave sp_main; end if;
    if isnull(ip_id) then leave sp_main; end if;
    if isnull(ip_tag) then leave sp_main; end if;
	-- ensure that the employee is currently working for the service
	-- ensure that the selected drone is owned by the same service and is a leader and not follower
	-- ensure that the employee isn't a manager
    -- ensure that the employee is a valid pilot
    if (select count(*) from work_for where id = ip_id and ip_username = username) = 0
		then leave sp_main; end if;
	if (select count(*) from drones where id = ip_id and tag = ip_tag and isnull(swarm_id)) = 0
		then leave sp_main; end if;
	if (select count(*) from delivery_services where manager = ip_username) > 0
		then leave sp_main; end if;
	if (select count(*) from pilots where username = ip_username) = 0
		then leave sp_main; end if;
	update drones set flown_by = ip_username where ip_id = id and ip_tag = tag;
end //
delimiter ;
-- [15] join_swarm()
-- -----------------------------------------------------------------------------
/* This stored procedure takes a drone that is currently being directly controlled
by a pilot and has it join a swarm (i.e., group of drones) led by a different
directly controlled drone. A drone that is joining a swarm connot be leading a
different swarm at this time.  Also, the drones must be at the same location, but
they can be controlled by different pilots. */
-- -----------------------------------------------------------------------------
drop procedure if exists join_swarm;
delimiter //
create procedure join_swarm (in ip_id varchar(40), in ip_tag integer,
	in ip_swarm_leader_tag integer)
sp_main: begin
	if isnull(ip_id) then leave sp_main; end if;
    if isnull(ip_tag) then leave sp_main; end if;
    if isnull(ip_swarm_leader_tag) then leave sp_main; end if;
	-- ensure that the swarm leader is a different drone
	-- ensure that the drone joining the swarm is valid and owned by the service
    -- ensure that the drone joining the swarm is not already leading a swarm
	-- ensure that the swarm leader drone is directly controlled
	-- ensure that the drones are at the same location
	if (select count(*) from drones where id = ip_id and ip_tag = ip_swarm_leader_tag) > 0
		then leave sp_main; end if;
	if (select count(*) from drones where ip_id in (select id from drones where tag = ip_swarm_leader_tag)) = 0
		then leave sp_main; end if;
	if (select count(*) from drones where swarm_id = ip_id and swarm_tag = ip_tag) > 0
		then leave sp_main; end if;
	if (select count(*) from drones where id = ip_id and ip_swarm_leader_tag = tag and isnull(flown_by)) > 0
		then leave sp_main; end if;
	if (select count(distinct hover) from drones where (id = ip_id and ip_swarm_leader_tag = tag) or (id = ip_id and tag = ip_tag)) > 1 or 
		(select count(distinct hover) from drones where (id = ip_id and ip_swarm_leader_tag = tag) or (id = ip_id and tag = ip_tag)) = 0
		then leave sp_main; end if;
	update drones set swarm_id = ip_id where ip_id = id and ip_tag = tag;
    update drones set swarm_tag = ip_swarm_leader_tag where ip_id = id and ip_tag = tag;
    update drones set flown_by = null where ip_id = id and ip_tag = tag;

	
end //
delimiter ;


-- [16] leave_swarm()
-- -----------------------------------------------------------------------------
/* This stored procedure takes a drone that is currently in a swarm and returns
it to being directly controlled by the same pilot who's controlling the swarm. */
-- -----------------------------------------------------------------------------
drop procedure if exists leave_swarm;
delimiter //
create procedure leave_swarm (in ip_id varchar(40), in ip_swarm_tag integer)
sp_main: begin
	if isnull(ip_id) then leave sp_main; end if;
    if isnull(ip_swarm_tag) then leave sp_main; end if;
	-- ensure that the selected drone is owned by the service and flying in a swarm
	if (select count(*) from drones where ip_id in (select id from drones where tag = ip_swarm_tag)) = 0
		then leave sp_main; end if;
	if (select count(*) from drones where ip_id in (select id from drones where (tag = ip_swarm_tag) and !(isnull(swarm_id) and isnull(swarm_tag)))) = 0
		then leave sp_main; end if;
	select flown_by into @flyer from drones where (select swarm_tag from drones where ip_id = id and ip_swarm_tag = tag) = tag and ip_id = id;
    update drones set swarm_id = null where ip_id = id and ip_swarm_tag = tag;
    update drones set swarm_tag = null where ip_id = id and ip_swarm_tag = tag;
    update drones set flown_by = @flyer where ip_id = id and ip_swarm_tag = tag;
end //
delimiter ;

-- [17] load_drone()
-- -----------------------------------------------------------------------------
/* This stored procedure allows us to add some quantity of fixed-size packages of
a specific ingredient to a drone's payload so that we can sell them for some
specific price to other restaurants.  The drone can only be loaded if it's located
at its delivery service's home base, and the drone must have enough capacity to
carry the increased number of items.

The change/delta quantity value must be positive, and must be added to the quantity
of the ingredient already loaded onto the drone as applicable.  And if the ingredient
already exists on the drone, then the existing price must not be changed. */
-- -----------------------------------------------------------------------------
drop procedure if exists load_drone;
delimiter //
create procedure load_drone (in ip_id varchar(40), in ip_tag integer, in ip_barcode varchar(40),
	in ip_more_packages integer, in ip_price integer)
sp_main: begin
	if isnull(ip_id) then leave sp_main; end if;
    if isnull(ip_tag) then leave sp_main; end if;
    if isnull(ip_barcode) then leave sp_main; end if;
    if isnull(ip_more_packages) then leave sp_main; end if;
    if isnull(ip_price) then leave sp_main; end if;

	-- ensure that the drone being loaded is owned by the service
    if (ip_id not in (select id from drones where tag = ip_tag)) then leave sp_main; end if;
    if (ip_id not in (select id from delivery_services)) then leave sp_main; end if;
	-- ensure that the ingredient is valid
    if (ip_barcode not in (select barcode from ingredients)) then leave sp_main; end if;
    -- ensure that the drone is located at the service home base
    if ((select hover from drones where (id = ip_ID) and (tag = ip_tag)) != (select home_base from delivery_services where (id = ip_id)))
    then leave sp_main; end if;
	-- ensure that the quantity of new packages is greater than zero
    if (ip_more_packages <= 0) then leave sp_main; end if;
	-- ensure that the drone has sufficient capacity to carry the new packages
    set @addedcapacity = (ip_more_packages)	;
    if ((select capacity from drones where (drones.id = ip_id) and (drones.tag = ip_tag)) - @addedcapacity) < 0 then leave sp_main; end if;
    -- add more of the ingredient to the drone
    update drones set capacity = capacity - @addedcapacity where drones.tag = ip_tag and drones.id = ip_id;
    if ((select count(*) from payload where ip_id = id and ip_tag = tag and ip_barcode = barcode) > 0) then
	update payload set quantity = quantity + ip_more_packages where id = ip_id and tag = ip_tag and barcode = ip_barcode; leave sp_main; end if;
    insert into payload values(ip_id, ip_tag, ip_barcode, ip_more_packages, ip_price);
end //
delimiter ;

-- [18] refuel_drone()
-- -----------------------------------------------------------------------------
/* This stored procedure allows us to add more fuel to a drone. The drone can only
be refueled if it's located at the delivery service's home base. */
-- -----------------------------------------------------------------------------
drop procedure if exists refuel_drone;
delimiter //
create procedure refuel_drone (in ip_id varchar(40), in ip_tag integer, in ip_more_fuel integer)
sp_main: begin
	if isnull(ip_id) then leave sp_main; end if;
    if isnull(ip_tag) then leave sp_main; end if;
    if isnull(ip_more_fuel) then leave sp_main; end if;
    
	-- ensure that the drone being switched is valid and owned by the service
    if (ip_id not in (select id from delivery_services)) then leave sp_main; end if;
	if (select count(*) from drones where id = ip_id and tag = ip_tag) = 0 then leave sp_main; end if;

    -- ensure that the drone is located at the service home base
    if ((select hover from drones where (id = ip_ID) and (tag = ip_tag)) != (select home_base from delivery_services where (ID = ip_id)))
    then leave sp_main; end if;
    
    if (ip_more_fuel <= 0) then leave sp_main; end if;

	update drones set fuel = fuel + ip_more_fuel where id = ip_id and tag = ip_tag;

end //
delimiter ;

-- [19] fly_drone()
-- -----------------------------------------------------------------------------
/* This stored procedure allows us to move a single or swarm of drones to a new
location (i.e., destination). The main constraints on the drone(s) being able to
move to a new location are fuel and space.  A drone can only move to a destination
if it has enough fuel to reach the destination and still move from the destination
back to home base.  And a drone can only move to a destination if there's enough
space remaining at the destination.  For swarms, the flight directions will always
be given to the lead drone, but the swarm must always stay together. */
-- -----------------------------------------------------------------------------
drop function if exists fuel_required;
delimiter //
create function fuel_required (ip_departure varchar(40), ip_arrival varchar(40))
	returns integer reads sql data
begin
	if (ip_departure = ip_arrival) then return 0;
    else return (select 1 + truncate(sqrt(power(arrival.x_coord - departure.x_coord, 2) + power(arrival.y_coord - departure.y_coord, 2)), 0) as fuel
		from (select x_coord, y_coord from locations where label = ip_departure) as departure,
        (select x_coord, y_coord from locations where label = ip_arrival) as arrival);
	end if;
end //
delimiter ;

drop procedure if exists fly_drone;
delimiter //
create procedure fly_drone (in ip_id varchar(40), in ip_tag integer, in ip_destination varchar(40))
sp_main: begin
    if isnull(ip_id) then leave sp_main; end if;
    if isnull(ip_tag) then leave sp_main; end if;
    if isnull(ip_destination) then leave sp_main; end if;
    -- ensure that the lead drone being flown is directly controlled and owned by the service
    if (select count(*) from drones where (ip_id = id and ip_tag = tag) and isnull(flown_by)) > 0
        then leave sp_main; end if;
    -- ensure that the destination is a valid location
    if (select count(*) from locations where label = ip_destination) = 0
        then leave sp_main; end if;
    -- ensure that the drone isn't already at the location
    if (fuel_required((select hover from drones where (ip_id = id and ip_tag = tag)), ip_destination)) = 0
        then leave sp_main; end if;
    -- ensure that the drone/swarm has enough fuel to reach the destination and (then) home base
    select count(*) from drones where (ip_id = id and ip_tag = tag) or (swarm_id = ip_id and swarm_tag = ip_tag) into @numberDrones;
    select hover from drones where (ip_id = id and ip_tag = tag) into @currLocation;
    select home_base from delivery_services where ip_id = id into @homeBase;
    if ((select count(fuel) from drones where ((ip_id = id and ip_tag = tag) or (swarm_id = ip_id and swarm_tag = ip_tag)) and 
    fuel > ((fuel_required(@currLocation, ip_destination)) + (fuel_required(ip_destination, @homeBase))))
    <
    (@numberDrones))
        then leave sp_main; end if;
    -- ensure that the drone/swarm has enough space at the destination for the flight
    if ((select count(*) from drones where (ip_id = id and ip_tag = tag) or (swarm_id = ip_id and swarm_tag = ip_tag)) 
    >
    (select space from locations where label = ip_destination))
		then leave sp_main; end if;
	select fuel_required((select hover from drones where (ip_id = id and ip_tag = tag)), ip_destination) into @required;
    update drones set fuel = fuel - @required
		where (ip_id = id and ip_tag = tag) or (swarm_id = ip_id and swarm_tag = ip_tag);
    update locations set space = space + (select count(*) from drones where (ip_id = id and ip_tag = tag) or (swarm_id = ip_id and swarm_tag = ip_tag))
		where (label = (select hover from drones where (ip_id = id and ip_tag = tag)));
	update drones set hover = ip_destination
		where (ip_id = id and ip_tag = tag) or (swarm_id = ip_id and swarm_tag = ip_tag);
	update locations set space = space - (select count(*) from drones where (ip_id = id and ip_tag = tag) or (swarm_id = ip_id and swarm_tag = ip_tag))
		where (label = ip_destination);
end //
delimiter ;

-- [20] purchase_ingredient()
-- -----------------------------------------------------------------------------
/* This stored procedure allows a restaurant to purchase ingredients from a drone
at its current location.  The drone must have the desired quantity of the ingredient
being purchased.  And the restaurant must have enough money to purchase the
ingredients.  If the transaction is otherwise valid, then the drone and restaurant
information must be changed appropriately.  Finally, we need to ensure that all
quantities in the payload table (post transaction) are greater than zero. */
-- -----------------------------------------------------------------------------
drop procedure if exists purchase_ingredient;
delimiter //
create procedure purchase_ingredient (in ip_long_name varchar(40), in ip_id varchar(40),
	in ip_tag integer, in ip_barcode varchar(40), in ip_quantity integer)
sp_main: begin
	if isnull(ip_long_name) then leave sp_main; end if;
    if isnull(ip_id) then leave sp_main; end if;
    if isnull(ip_tag) then leave sp_main; end if;
    if isnull(ip_barcode) then leave sp_main; end if;
    if isnull(ip_quantity) then leave sp_main; end if;
	-- ensure that the restaurant is valid
    if not exists (select 1 from restaurants where long_name = ip_long_name)
    then leave sp_main;
    end if;
    -- ensure that the drone is valid and exists at the resturant's location
    if not (exists (select 1 from drones where tag = ip_tag and id = ip_id) and exists (select 1 from drones where hover = (select location from restaurants where long_name = ip_long_name) and id = ip_id and tag = ip_tag))
    then leave sp_main;
    end if;
	-- ensure that the drone has enough of the requested ingredient
    if not exists (select 1 from payload where tag = ip_tag and id = ip_id and barcode = ip_barcode and quantity >= ip_quantity)
    then leave sp_main;
    end if;
	-- update the drone's payload
    update payload 
    set quantity = quantity - ip_quantity 
    where tag = ip_tag and id = ip_id and barcode = ip_barcode;
    -- update the monies spent and gained for the drone and restaurant
    update restaurants
    set spent = spent + ip_quantity * (select price from payload where tag = ip_tag and id = ip_id and barcode = ip_barcode)
    where long_name = ip_long_name;
    
    update drones
    set sales = sales + ip_quantity * (select price from payload where tag = ip_tag and id = ip_id and barcode = ip_barcode)
    where tag = ip_tag and id = ip_id;
    update drones
    set capacity = capacity + ip_quantity where tag = ip_tag and id = ip_id;
    -- ensure all quantities in the payload table are greater than zero
	if ((select quantity from payload where ip_id = id and ip_tag = tag and ip_barcode = barcode) <= 0) then delete from payload where ip_id = id and ip_tag = tag and ip_barcode = barcode;
    leave sp_main;
    end if;
end //
delimiter ;

-- [21] remove_ingredient()
-- -----------------------------------------------------------------------------
/* This stored procedure removes an ingredient from the system.  The removal can
occur if, and only if, the ingredient is not being carried by any drones. */
-- -----------------------------------------------------------------------------
drop procedure if exists remove_ingredient;
delimiter //
create procedure remove_ingredient (in ip_barcode varchar(40))
sp_main: begin
	if isnull(ip_barcode) then leave sp_main; end if;
    
	-- ensure that the ingredient exists
	if (ip_barcode not in (select barcode from ingredients)) then leave sp_main; end if;
    -- ensure that the ingredient is not being carried by any drones
	if (ip_barcode in (select barcode from payload)) then leave sp_main; end if;
    delete from ingredients WHERE barcode=ip_barcode;
end //
delimiter ;

-- [22] remove_drone()
-- -----------------------------------------------------------------------------
/* This stored procedure removes a drone from the system.  The removal can
occur if, and only if, the drone is not carrying any ingredients, and if it is
not leading a swarm. */
-- -----------------------------------------------------------------------------
drop procedure if exists remove_drone;
delimiter //
create procedure remove_drone (in ip_id varchar(40), in ip_tag integer)
sp_main: begin
	if isnull(ip_id) then leave sp_main; end if;
    if isnull(ip_tag) then leave sp_main; end if;
	-- ensure that the drone exists
	if (select count(*) from drones where id = ip_id and tag = ip_tag) = 0 then leave sp_main; end if;
    -- ensure that the drone is not carrying any ingredients
	if (select count(*) from payload where id = ip_id and tag = ip_tag) > 0 then leave sp_main; end if;
    delete from drones where id=ip_id and tag=ip_tag;
	-- ensure that the drone is not leading a swarm
end //
delimiter ;

-- [23] remove_pilot_role()
-- -----------------------------------------------------------------------------
/* This stored procedure removes a pilot from the system.  The removal can
occur if, and only if, the pilot is not controlling any drones.  Also, if the
pilot also has a worker role, then the worker information must be maintained;
otherwise, the pilot's information must be completely removed from the system. */
-- -----------------------------------------------------------------------------
drop procedure if exists remove_pilot_role;
delimiter //
create procedure remove_pilot_role (in ip_username varchar(40))
sp_main: begin
	if isnull(ip_username) then leave sp_main; end if;
	-- ensure that the pilot exists
    if not exists (select 1 from pilots where username = ip_username)
    then leave sp_main;
    end if;
    -- ensure that the pilot is not controlling any drones
    if exists (select 1 from drones where flown_by = ip_username)
    then leave sp_main;
    end if;
    -- remove all remaining information unless the pilot is also a worker
    if exists (select 1 from workers where username = ip_username)
    then delete from pilots where username = ip_username;
    leave sp_main;
    end if;
    
    delete from work_for where username = ip_username;
    delete from users where username = ip_username;
end //
delimiter ;

create or replace view display_owner_view as
select users.username, first_name, last_name, address, count(long_name) as num_restaurants, count(distinct location) as num_places, 
ifnull(max(rating), 0) as highs, ifnull(min(rating), 0) as lows, ifnull(sum(spent), 0) as debt 
from users, restaurant_owners left outer join restaurants on restaurant_owners.username = funded_by where users.username = restaurant_owners.username 
group by restaurant_owners.username;


-- [25] display_employee_view()
-- -----------------------------------------------------------------------------
/* This view displays information in the system from the perspective of an employee.
For each employee, it includes the username, tax identifier, hiring date and
experience level, along with the license identifer and piloting experience (if
applicable), and a 'yes' or 'no' depending on the manager status of the employee. */
-- -----------------------------------------------------------------------------
create or replace view display_employee_view as
select employees.username as username, taxID, salary, hired, employees.experience as employee_experience,
IFNULL(pilots.licenseID, 'n/a') as licenseID,
IFNULL(pilots.experience, 'n/a') as pilot_experience,
if(employees.username in (select manager from delivery_services), 'yes', 'no') as
manager_status
from employees left join pilots on employees.username = pilots.username;



-- [26] display_pilot_view()
-- -----------------------------------------------------------------------------
/* This view displays information in the system from the perspective of a pilot.
For each pilot, it includes the username, licenseID and piloting experience, along
with the number of drones that they are controlling. */
-- -----------------------------------------------------------------------------
create or replace view display_pilot_view as
select username, licenseID, experience, count(id) + count(children) as num_drones, count(distinct hover) as num_locations
from
(select username, licenseID, experience, hover, tag, id
from pilots
left outer join drones
on username = flown_by) as x
left outer join
(select swarm_tag, swarm_id, count(*) as children
from drones
where swarm_id is not null and swarm_tag is not null
group by swarm_id, swarm_tag) as y
on id = swarm_id and tag = swarm_tag
group by username;
-- [27] display_location_view()
-- -----------------------------------------------------------------------------
/* This view displays information in the system from the perspective of a location.
For each location, it includes the label, x- and y- coordinates, along with the
number of restaurants, delivery services and drones at that location. */
-- -----------------------------------------------------------------------------
create or replace view display_location_view as
select label, x_coord, y_coord, count(distinct restaurants.long_name)as num_restaurants, count(distinct delivery_services.id) as num_delivery_services, (count(DISTINCT CONCAT(drones.id, '_', drones.tag))) as num_drones
from locations
left outer join restaurants
on label = location
left outer join delivery_services
on label = home_base
left outer join drones
on label = hover
group by label;

-- [28] display_ingredient_view()
-- -----------------------------------------------------------------------------
/* This view displays information in the system from the perspective of the ingredients.
For each ingredient that is being carried by at least one drone, it includes a list of
the various locations where it can be purchased, along with the total number of packages
that can be purchased and the lowest and highest prices at which the ingredient is being
sold at that location. */
-- -----------------------------------------------------------------------------
create or replace view display_ingredient_view as
select ingredient as ingredient_name, location, sum(quantity) as amount_available, min(price) as low_price, max(price) as high_price
from
(select ingredient, location, quantity, price
from
(select ingredients.iname as ingredient, drones.hover as location, 
	(select quantity 
	 from payload
     where barcode = ingredients.barcode and tag = drones.tag and id = drones.id) as quantity, 
	(select price
     from payload
     where barcode = ingredients.barcode and tag = drones.tag and id = drones.id) as price
from ingredients
cross join drones) as x
where quantity is not null) as y
group by ingredient, location
order by ingredient;


-- [29] display_service_view()
-- -----------------------------------------------------------------------------
/* This view displays information in the system from the perspective of a delivery
service.  It includes the identifier, name, home base location and manager for the
service, along with the total sales from the drones.  It must also include the number
of unique ingredients along with the total cost and weight of those ingredients being
carried by the drones. */
-- -----------------------------------------------------------------------------
create or replace view display_service_view as
select id, long_name, home_base, manager, revenue, count(distinct ingredient) as ingredients_carried, sum(total_price) as cost_carried, sum(total_weight) as weight_carried
from 
(select delivery_services.id as id, long_name, home_base, manager, sum(sales) as revenue
from delivery_services
left join drones
on delivery_services.id = drones.id
group by id) as f
left join
(select tag, serviceID, ingredient, quantity, quantity * price as total_price, quantity * weight as total_weight
from
(select drones.tag as tag, drones.id as serviceID, ingredients.iname as ingredient,
	(select quantity 
	 from payload
     where barcode = ingredients.barcode and tag = drones.tag and id = drones.id) as quantity, 
	(select price
     from payload
     where barcode = ingredients.barcode and tag = drones.tag and id = drones.id) as price,
     ingredients.weight as weight
from ingredients
cross join drones) as x
where quantity is not null) as y
on f.id = y.serviceID
group by id, long_name, home_base, manager, revenue;
