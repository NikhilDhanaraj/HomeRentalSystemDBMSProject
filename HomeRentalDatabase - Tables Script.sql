--tables required
create table users(
    userid int NOT NULL primary key,
    uname varchar2(20),
    age int NOT NULL,
    dno int NOT NULL,
    street varchar2(10),
    city varchar2(20),
    zip number NOT NULL,
    username varchar2(20),
    password varchar2(20));


create table contact(
    userID int NOT NULL,
    phone int NOT NULL,
    primary key (userID, phone));


create table manager(
    userID int NOT NULL,
    foreign key(userID) REFERENCES users(userid));
create table dba(
    userID int NOT NULL,
    foreign key(userID) REFERENCES users(userid));


alter table contact add constraint user_contact foreign key(userID) references users(userid);




create table owner_prop(
    userID int NOT NULL,
    pid int NOT NULL primary key,
    avail_from date,
    avail_till date,
    rpm int,
    yhr int,
    t_area int NOT NULL,
    p_area int NOT NULL,
    floors int, yoc int,
    yearofConstruct VARCHAR2(20),  
    loc varchar2(20),
    address varchar2(30),
    foreign key(userID) REFERENCES users(userid));


create table res_prop(
    pid int NOT NULL,
    nbr int,  
    rprop_type varchar2(100),
    foreign key(pid) REFERENCES owner_prop(pid));


create table comm_prop(
    pid int NOT NULL,
    cprop_type varchar2(100),
    foreign key(pid) REFERENCES owner_prop(pid));


create table tenant_prop(
    userID int NOT NULL,
    pid int NOT NULL,
    st_date date,
    end_date date,
    rent int,
    hike int,
    foreign key(userID) REFERENCES users(userid),
    foreign key(pid) references owner_prop(pid));


create table history_prop(
    userID int NOT NULL,
    pid int NOT NULL,
    st_date date,
    end_date date,
    rent int,
    hike int,
    foreign key(userID) REFERENCES users(userid),
    foreign key(pid) references owner_prop(pid));



