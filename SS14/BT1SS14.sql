CALL PayHospitalFee(1,5000);

SELECT * 
FROM Wallets
WHERE patient_id = 1;

SELECT *
FROM Patient_Invoices
WHERE patient_id = 1;

DROP PROCEDURE IF EXISTS PayHospitalFee;

DELIMITER //

CREATE PROCEDURE PayHospitalFee(IN p_patient_id INT, IN p_amount DECIMAL(18,2))
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        -- Nếu có lỗi, hoàn tác toàn bộ
        ROLLBACK;
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Giao dịch thất bại: Đã hoàn tác!';
    END;

    START TRANSACTION;

    UPDATE Wallets 
    SET balance = balance - p_amount 
    WHERE patient_id = p_patient_id;
    
    UPDATE Patient_Invoices 
    SET total_due = total_due - p_amount 
    WHERE patient_id = p_patient_id;

    COMMIT;
END //

DELIMITER ;

CALL PayHospitalFee(1,5000);
