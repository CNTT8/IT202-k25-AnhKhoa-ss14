CALL PayHospitalFee(1,200000);

SELECT * 
FROM Wallets
WHERE patient_id = 1;

SELECT *
FROM Patient_Invoices
WHERE patient_id = 1;

DROP PROCEDURE IF EXISTS PayHospitalFee;

DELIMITER //

CREATE PROCEDURE PayHospitalFee(
    IN p_patient_id INT,
    IN p_amount DECIMAL(10,2)
)
BEGIN

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN

        ROLLBACK;

    END;

    START TRANSACTION;

    UPDATE Wallets
    SET balance = balance - p_amount
    WHERE patient_id = p_patient_id;

    UPDATE Patient_Invoices
    SET debt_amount = debt_amount - p_amount
    WHERE patient_id = p_patient_id;

    COMMIT;

END //

DELIMITER ;

CALL PayHospitalFee(1,200000);

SELECT *
FROM Wallets
WHERE patient_id = 1;

SELECT *
FROM Patient_Invoices
WHERE patient_id = 1;