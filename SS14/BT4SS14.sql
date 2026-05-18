DROP PROCEDURE IF EXISTS PayByWallet;

DELIMITER //

CREATE PROCEDURE PayByWallet(
    IN p_patient_id INT,
    IN p_amount DECIMAL(10,2),
    OUT p_message VARCHAR(255)
)
BEGIN

    DECLARE v_balance DECIMAL(10,2);
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN

        ROLLBACK;

        SET p_message = 'Loi: He thong gap su co';

    END;

    START TRANSACTION;

    IF p_amount <= 0 THEN

        ROLLBACK;

        SET p_message = 'Loi: So tien thanh toan khong hop le';

    ELSE

        SELECT balance
        INTO v_balance
        FROM Wallets
        WHERE patient_id = p_patient_id;

        IF v_balance < p_amount THEN

            ROLLBACK;

            SET p_message = 'Loi: So du vi khong du';

        ELSE

            UPDATE Wallets
            SET balance = balance - p_amount
            WHERE patient_id = p_patient_id;
            UPDATE Patient_Invoices
            SET debt_amount = debt_amount - p_amount
            WHERE patient_id = p_patient_id;
            COMMIT;

            SET p_message = 'Thanh toan thanh cong';

        END IF;

    END IF;

END //

DELIMITER ;

CALL PayByWallet(
    1,
    100000,
    @message
);

SELECT @message;

CALL PayByWallet(
    1,
    9999999,
    @message
);

SELECT @message;

CALL PayByWallet(
    1,
    -50000,
    @message
);

SELECT @message;