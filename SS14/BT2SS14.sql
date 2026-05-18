DROP PROCEDURE IF EXISTS TransferBed;

DELIMITER //

CREATE PROCEDURE TransferBed(
    IN p_patient_id INT,
    IN p_new_bed_id INT
)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
 
        ROLLBACK;
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Giao dịch thất bại';
    END;

    START TRANSACTION;

    UPDATE Beds
    SET patient_id = NULL
    WHERE patient_id = p_patient_id;

    UPDATE Beds
    SET patient_id = p_patient_id
    WHERE bed_id = p_new_bed_id;

    COMMIT;
END //

DELIMITER ;
