DROP PROCEDURE IF EXISTS ProcessEquipmentPurchase;

DELIMITER //

CREATE PROCEDURE ProcessEquipmentPurchase(
    IN p_patient_id INT,
    IN p_product_id INT,
    IN p_quantity INT,
    OUT p_message VARCHAR(255)
)
BEGIN

    DECLARE v_stock INT;
    DECLARE v_price DECIMAL(10,2);
    DECLARE v_total DECIMAL(10,2);

    DECLARE v_balance DECIMAL(10,2);
    DECLARE v_wallet_status VARCHAR(20);
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN

        ROLLBACK;

        SET p_message = 'Loi: He thong gap su co';

    END;

    START TRANSACTION;

    SELECT stock_quantity, price
    INTO v_stock, v_price
    FROM Products
    WHERE product_id = p_product_id;

    SELECT balance, status
    INTO v_balance, v_wallet_status
    FROM Wallets
    WHERE patient_id = p_patient_id;

    IF v_wallet_status = 'Inactive' THEN

        ROLLBACK;

        SET p_message = 'That bai: Vi dang bi khoa';

    ELSEIF p_quantity > v_stock THEN

        ROLLBACK;

        SET p_message = 'That bai: Kho khong du san pham';

    ELSE

        SET v_total = p_quantity * v_price;
        IF v_total > v_balance THEN

            ROLLBACK;

            SET p_message = 'That bai: So du vi khong du';

        ELSE

            UPDATE Products
            SET stock_quantity = stock_quantity - p_quantity
            WHERE product_id = p_product_id;
            UPDATE Wallets
            SET balance = balance - v_total
            WHERE patient_id = p_patient_id;
            COMMIT;

            SET p_message = 'Thanh cong: Da xu ly don hang';

        END IF;

    END IF;

END //

DELIMITER ;

CALL ProcessEquipmentPurchase(
    1,
    1,
    2,
    @message
);

SELECT @message;

CALL ProcessEquipmentPurchase(
    1,
    1,
    999,
    @message
);

SELECT @message;

CALL ProcessEquipmentPurchase(
    1,
    2,
    100,
    @message
);

SELECT @message;

CALL ProcessEquipmentPurchase(
    2,
    1,
    1,
    @message
);

SELECT @message;