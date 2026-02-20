import { join } from 'path';

export const config: any = {
    runner: 'local',
    specs: ['./test/**/*.ts'],
    maxInstances: 1,
    logLevel: 'info',
    framework: 'mocha',
    mochaOpts: { ui: 'bdd', timeout: 180000 },

    hostname: '127.0.0.1',
    port: 4723,
    path: '/',
    connectionRetryTimeout: 180000,
    connectionRetryCount: 3,
    services: ['appium'],

    capabilities: [
        {
            platformName: 'Android',
            'appium:deviceName': process.env.AVD_NAME || 'Medium_Phone_API_36.1',
            'appium:platformVersion': process.env.ANDROID_VERSION || '16',
            'appium:automationName': 'UiAutomator2',
            'appium:app': join(process.cwd(), './app/android/ApiDemos-debug.apk'),
            'appium:appPackage': 'io.appium.android.apis',
            'appium:appActivity': '.ApiDemos',
            'appium:noReset': true,
            'appium:newCommandTimeout': 300
        }
    ],

    reporters: [
        'spec',
        ['allure', {
            outputDir: 'allure-results',
            disableWebdriverStepsReporting: false,
            disableWebdriverScreenshotsReporting: false
        }]
    ],

    before: async () => {
        // Make chai expect global
        // @ts-ignore
        global.expect = (await import('chai')).expect;
    },

    afterTest: async (test: any, context: any, { error }: any) => {
        if (error) {
            const timestamp = Date.now();
            await driver.saveScreenshot(`./allure-results/error-${timestamp}.png`);
            console.error(`Test failed: ${test.title}\n${error.stack}`);
        }
    }
};