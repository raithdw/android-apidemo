import { expect } from 'chai';

describe('Android Demo App', () => {
   
    it('should open the Views menu and interact with Buttons', async () => {
        const viewsMenu = $('~Views');
        await viewsMenu.waitForDisplayed({ timeout: 10000 });
        await viewsMenu.click();

        const buttonsMenu = $('~Buttons');
        await buttonsMenu.waitForDisplayed({ timeout: 10000 });
        await buttonsMenu.click();

        const normalButton = $('~Normal');
        await normalButton.waitForDisplayed({ timeout: 10000 });
        await normalButton.click();

        const toggleButton = $('~Toggle');
        await toggleButton.waitForDisplayed({ timeout: 10000 });
        await toggleButton.click();

        const toggleState = await toggleButton.getAttribute('checked');
        expect(toggleState === 'true' || toggleState === 'false').to.be.true;
        await driver.back(); 
        await driver.back();
        const appMenu = $('~App');
        expect(await appMenu.isDisplayed(), 'App menu should be visible after nazvigation').to.be.true;
    });

    it('should open the Preferences menu and toggle CheckBox', async () => {
        const preferencesMenu = $('~Preference');
        await preferencesMenu.waitForDisplayed({ timeout: 10000 });
        await preferencesMenu.click();

        const preferenceDependencies = $('~3. Preference dependencies');
        await preferenceDependencies.waitForDisplayed({ timeout: 10000 });
        await preferenceDependencies.click();

        const wifiCheckbox = $('id=android:id/checkbox');
        await wifiCheckbox.waitForDisplayed({ timeout: 10000 });

        const currentState = await wifiCheckbox.getAttribute('checked');

        if (currentState === 'false') {
            await wifiCheckbox.click();
        }

        expect(await wifiCheckbox.getAttribute('checked')).to.equal('true');
    });

});