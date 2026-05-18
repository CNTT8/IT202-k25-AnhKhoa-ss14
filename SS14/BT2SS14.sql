DROP PROCEDURE IF EXISTS TransferBed;

DELIMITER //

CREATE PROCEDURE TransferBed(
    IN p_patient_id INT,
    IN p_old_bed_id INT,
    IN p_new_bed_id INT
)
BEGIN

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN

        ROLLBACK;

    END;

    START TRANSACTION;

    UPDATE Beds
    SET status = 'Empty',
        patient_id = NULL
    WHERE bed_id = p_old_bed_id;
    UPDATE Beds
    SET status = 'Occupied',
        patient_id = p_patient_id
    WHERE bed_id = p_new_bed_id;
    COMMIT;

END //

DELIMITER ;

CALL TransferBed(1,101,102);

SELECT *
FROM Beds;