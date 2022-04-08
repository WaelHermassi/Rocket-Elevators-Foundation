$(document).ready(function () {
    "use strict";

    let buildingType_select = document.getElementById("building_type");
    let selectedBuildingType = document.getElementById("submit_building_type");
    let buildingType =
        buildingType_select.options[buildingType_select.selectedIndex].value;
    let estimateNumElv_div = document.querySelector(".estimate-num-elv");
    let numApt_input = document
        .getElementById("number-of-apartments")
        .querySelector("input");
    let numFloors_input = document
        .getElementById("number-of-floors")
        .querySelector("input");
    let numBasements_input = document
        .getElementById("number-of-basements")
        .querySelector("input");
    let numElevators_input = document
        .getElementById("number-of-elevators")
        .querySelector("input");
    let maxOcc_input = document
        .getElementById("maximum-occupancy")
        .querySelector("input");
    // let displayCalcElv_input = document
    //     .getElementById("elevator-amount")
    //     .querySelector("input");
    let displayCalcElv_input = document.getElementById("submit_estimated_elev");

    let productLineSelection_div = document.querySelector(".product-line");
    let selectedProductLine = document.getElementById("submit_product_line");
    let radioBtns_div = document.querySelector(".radio-btns");
    let warning_p = document.getElementById("warning");

    let finalPricingDisplay_div = document.querySelector(
        ".final-pricing-display"
    );
    let displayUnitPrice_input = document
        .getElementById("elevator-unit-price")
        .querySelector("input");
    let displayElvTotalPrice_input = document
        .getElementById("elevator-total-price")
        .querySelector("input");
    let displayInstallFee_input = document
        .getElementById("installation-fees")
        .querySelector("input");
    let displayEstTotalCost_input = document
        .getElementById("final-price")
        .querySelector("input");

    let userInfo_div = document.querySelector(".user-info");
    let submitForm_div = document.querySelector(".submit-form");
    let companyName_field = document.getElementById("company-name");
    let userEmail_field = document.getElementById("user-email");

    let formatter = new Intl.NumberFormat("en-US", {
        style: "currency",
        currency: "CAD",
    });
    const buildingTypeFields = {
        residential: [
            "number-of-apartments",
            "number-of-floors",
            "number-of-basements",
        ],
        commercial: [
            "number-of-floors",
            "number-of-basements",
            "number-of-companies",
            "number-of-parking-spots",
            "number-of-elevators",
        ],
        corporate: [
            "number-of-floors",
            "number-of-basements",
            "number-of-parking-spots",
            "number-of-corporations",
            "maximum-occupancy",
        ],
        hybrid: [
            "number-of-floors",
            "number-of-basements",
            "number-of-companies",
            "number-of-parking-spots",
            "maximum-occupancy",
            "business-hours",
        ],
    };
    const unitPrices = {
        standard: 7565,
        premium: 12345,
        excelium: 15400,
    };
    const installPercentFees = {
        standard: 10,
        premium: 13,
        excelium: 16,
    };

    /////////////// CALCULATIONS
    function calcResElv(numFloors, numApts) {
        let elvReq = Math.ceil(numApts / numFloors / 6);
        let elvColumn = numFloors / 20 <= 1 ? 1 : Math.ceil(numFloors / 20);
        let totalElvReq = elvReq * elvColumn;
        return totalElvReq == 0 ? 1 : totalElvReq;
    }

    function calcCorpHybridElv(numFloors, numBase, maxOcc) {
        let stories = numFloors + numBase;
        let elvColumn = Math.ceil(stories / 20);

        let totalOcc = maxOcc * numFloors;
        let elvByOcc = Math.ceil(totalOcc / 1000);

        let elvByColumn = Math.ceil(elvByOcc / elvColumn);
        let totalElvReq = elvByColumn * elvColumn;

        return totalElvReq == 0 ? 1 : totalElvReq;
    }

    function calcInstallFee(totalPrice, installPercentFee) {
        return (installPercentFee / 100) * totalPrice;
    }

    /////////////// DISPLAY
    function resetForm() {
        estimateNumElv_div.style.display = "none";
        estimateNumElv_div.querySelectorAll("div").forEach((el) => {
            el.querySelectorAll("input[type='number']").forEach((input) => {
                input.value = "";
            });
            el.querySelectorAll("div.col-4").forEach((div) => {
                div.classList.add("d-none");
            });
        });
        displayCalcElv_input.value = "";
        productLineSelection_div.style.display = "none";
        warning_p.style.display = "none";
        productLineSelection_div
            .querySelectorAll("input[type='radio']")
            .forEach((radioBtn) => {
                radioBtn.checked = false;
            });

        finalPricingDisplay_div.style.display = "none";
        finalPricingDisplay_div
            .querySelectorAll("input[type='text']")
            .forEach((input) => {
                input.setAttribute("value", "");
            });
        companyName_field.setAttribute("value", "");
        userEmail_field.setAttribute("value", "");
    }

    function displayBuildingFields(buildingType) {
        estimateNumElv_div.style.display = "block";
        estimateNumElv_div.querySelector(".step-description").style.display =
            "block";
        estimateNumElv_div.querySelector(".card-block").style.display = "block";
        estimateNumElv_div.querySelectorAll(".row").forEach((row) => {
            row.classList.remove("d-none");
        });
        for (let fieldID of buildingTypeFields[buildingType]) {
            estimateNumElv_div
                .querySelector(`div[id='${fieldID}']`)
                .classList.remove("d-none");
        }
        productLineSelection_div.style.display = "block";
        finalPricingDisplay_div.style.display = "block";
        submitForm_div.style.display = "block";
        userInfo_div.style.display = "block";
    }

    function displayElvCalcResult(buildingType) {
        let calculatedElv;
        if (buildingType == "commercial") {
            calculatedElv =
                numElevators_input.value == 0 ? 1 : numElevators_input.value;
            displayCalcElv_input.value = parseInt(numElevators_input.value);
        } else if (buildingType == "residential") {
            calculatedElv = calcResElv(
                parseInt(numFloors_input.value),
                parseInt(numApt_input.value)
            );
            displayCalcElv_input.value = calculatedElv;
        } else {
            calculatedElv = calcCorpHybridElv(
                parseInt(numFloors_input.value),
                parseInt(numBasements_input.value),
                parseInt(maxOcc_input.value)
            );
            displayCalcElv_input.value = calculatedElv;
        }
    }

    function displayPricing(productLine, numElv) {
        let unitPrice = unitPrices[productLine];
        let installPercentFee = installPercentFees[productLine];
        let subtotal = unitPrice * numElv;
        let totalInstallFee = calcInstallFee(subtotal, installPercentFee);
        let totalPrice = subtotal + totalInstallFee;
        displayUnitPrice_input.setAttribute(
            "value",
            formatter.format(unitPrice)
        );
        displayElvTotalPrice_input.setAttribute(
            "value",
            formatter.format(subtotal)
        );
        displayInstallFee_input.setAttribute(
            "value",
            formatter.format(totalInstallFee)
        );
        displayEstTotalCost_input.setAttribute(
            "value",
            formatter.format(totalPrice)
        );
    }

    function updatePricingDisplay() {
        if (!displayCalcElv_input.value) {
            warning_p.style.display = "block";
            this.checked = false;
        } else {
            let numElv = parseInt(displayCalcElv_input.value);
            warning_p.style.display = "none";
            try {
                let productLine = document.querySelector(
                    "input[name='product-line']:checked"
                ).id;
                selectedProductLine.setAttribute(
                    "value",
                    `${
                        productLine.charAt(0).toUpperCase() +
                        productLine.slice(1)
                    }`
                );
                displayPricing(productLine, numElv);
            } catch {
                // empty: waiting for user to select product line;
            }
        }
    }

    /////////////// VALIDATION
    function allBuildingFieldsCompleted(buildingType) {
        for (let fieldID of buildingTypeFields[buildingType]) {
            if (
                estimateNumElv_div.querySelector(`div[id='${fieldID}'] input`)
                    .value == ""
            ) {
                return false;
            }
        }
        return true;
    }

    /////////////////////////////////////MODEL////////////////////////////////////////

    radioBtns_div
        .querySelectorAll("input[type='radio']")
        .forEach((radioBtn) => {
            radioBtn.addEventListener("click", updatePricingDisplay);
        });

    buildingType_select.addEventListener("change", function () {
        resetForm();
        buildingType = this.value;
        if (buildingType == "---Select---") {
            resetForm();
        } else {
            selectedBuildingType.setAttribute(
                "value",
                `${
                    buildingType.charAt(0).toUpperCase() + buildingType.slice(1)
                }`
            );
            displayBuildingFields(buildingType);
            estimateNumElv_div.addEventListener("change", function () {
                if (!allBuildingFieldsCompleted(buildingType)) {
                    return;
                } else {
                    displayElvCalcResult(buildingType);
                    updatePricingDisplay();
                }
            });
        }
    });
});
