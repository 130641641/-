insert into Am_user (
user_id,
name,
age,
mail,
tel)
select 
user_id,
cast(age as varchar(50)),
age,
mail,
tel
from 
M_User
