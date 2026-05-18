DROP PROCEDURE IF EXISTS FindAvailableBed;
DROP PROCEDURE IF EXISTS HospitalizePatient;

DELIMITER //

CREATE PROCEDURE FindAvailableBed(
    IN p_department_id INT,
    OUT p_bed_id INT
)
BEGIN

    SELECT bed_id
    INTO p_bed_id
    FROM Beds
    WHERE department_id = p_department_id
      AND status = 'Empty'
    LIMIT 1;

END //

CREATE PROCEDURE HospitalizePatient(
    IN p_patient_id INT,
    IN p_doctor_id INT,
    IN p_appointment_date DATETIME,
    IN p_department_id INT,
    OUT p_message VARCHAR(255)
)
BEGIN

    DECLARE v_bed_id INT;
    DECLARE v_count INT;
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN

        ROLLBACK;

        SET p_message = 'Loi: He thong gap su co';

    END;

    SELECT COUNT(*)
    INTO v_count
    FROM Departments
    WHERE department_id = p_department_id;

    IF v_count = 0 THEN

        SET p_message = 'Tu choi: Khoa khong ton tai';

    ELSE

        SELECT COUNT(*)
        INTO v_count
        FROM Beds
        WHERE patient_id = p_patient_id
          AND status = 'Occupied';

        IF v_count > 0 THEN

            SET p_message = 'Tu choi: Benh nhan dang luu tru';

        ELSE

            CALL FindAvailableBed(
                p_department_id,
                v_bed_id
            );

            IF v_bed_id IS NULL THEN

                SET p_message = 'Tu choi: Khoa hien da het giuong';

            ELSE

                START TRANSACTION;
                INSERT INTO Appointments(
                    patient_id,
                    doctor_id,
                    appointment_date,
                    status
                )
                VALUES(
                    p_patient_id,
                    p_doctor_id,
                    p_appointment_date,
                    'Pending'
                );
                UPDATE Beds
                SET status = 'Occupied',
                    patient_id = p_patient_id
                WHERE bed_id = v_bed_id;
                COMMIT;

                SET p_message = 'Nhap vien thanh cong';

            END IF;

        END IF;

    END IF;

END //

DELIMITER ;

CALL HospitalizePatient(
    1,
    1,
    '2026-07-20 08:00:00',
    1,
    @message
);

SELECT @message;

CALL HospitalizePatient(
    2,
    1,
    '2026-07-20 09:00:00',
    99,
    @message
);

SELECT @message;

CALL HospitalizePatient(
    1,
    1,
    '2026-07-20 10:00:00',
    1,
    @message
);

SELECT @message;

CALL HospitalizePatient(
    3,
    1,
    '2026-07-20 11:00:00',
    999,
    @message
);

SELECT @message;