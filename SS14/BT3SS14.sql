DROP PROCEDURE IF EXISTS ProcessMedicineIssue;

DELIMITER //

CREATE PROCEDURE ProcessMedicineIssue(
    IN p_patient_id INT,
    IN p_medicine_id INT,
    IN p_quantity INT,
    OUT p_message VARCHAR(255)
)
BEGIN

    DECLARE v_stock INT;
    DECLARE v_price DECIMAL(10,2);
    DECLARE v_total DECIMAL(10,2);
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN

        ROLLBACK;

        SET p_message = 'Loi: He thong gap su co';

    END;

    START TRANSACTION;

    SELECT stock_quantity, price
    INTO v_stock, v_price
    FROM Medicines
    WHERE medicine_id = p_medicine_id;

    IF p_quantity > v_stock THEN

        ROLLBACK;

        SET p_message = 'Loi: So luong ton kho khong du';

    ELSE

        SET v_total = p_quantity * v_price;

        UPDATE Medicines
        SET stock_quantity = stock_quantity - p_quantity
        WHERE medicine_id = p_medicine_id;

        UPDATE Patient_Invoices
        SET debt_amount = debt_amount + v_total
        WHERE patient_id = p_patient_id;

        COMMIT;

        SET p_message = 'Da cap phat thanh cong';

    END IF;

END //

DELIMITER ;

CALL ProcessMedicineIssue(
    1,
    1,
    2,
    @message
);

SELECT @message;

SELECT *
FROM Medicines
WHERE medicine_id = 1;

SELECT *
FROM Patient_Invoices
WHERE patient_id = 1;

CALL ProcessMedicineIssue(
    1,
    1,
    100,
    @message
);

SELECT @message;