"""
SQL




When creating a stored procedure to create a
 user in the tbl_user table, first we need to check if a user
 with the same username already exists. If it exists we need to
  throw an error to the user, otherwise we'll create the user in
  the user table. Here is how the stored procedure sp_createUser
   would look



DELIMITER $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_createUser`(
    IN p_name VARCHAR(20),
    IN p_username VARCHAR(20),
    IN p_password TEXT
)
BEGIN
    if ( select exists (select 1 from tbl_user where user_username = p_username) ) THEN

        select 'Username Exists !!';

    ELSE

        insert into tbl_user
        (
            user_name,
            user_username,
            user_password
        )
        values
        (
            p_name,
            p_username,
            p_password
        );

    END IF;
END$$
DELIMITER ;

"""