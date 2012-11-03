/**
 * Site-specific JavaScript for http://www.missingnprpodcasts.com
 * Copyright 2012 Jimmy Theis, released under the MIT License
 * <https://github.com/jetheis/MissingNPRPodcasts>
 **/

(function() {
    'use strict';

    var subscriptionsContainer = $('.subscriptions');

    var apiKeyField = $('#apiKeyField'),
        apiKeyCheckButton = $('#apiKeyCheckButton');

    var morningEditionITunesButton = $('#morningEditionITunesButton'),
        morningEditionRssButton = $('#morningEditionRssButton');

    var allThingsConsideredITunesButton = $('#allThingsConsideredITunesButton'),
        allThingsConsideredRssButton = $('#allThingsConsideredRssButton');

    apiKeyCheckButton.click(function(e) {

        e.preventDefault();

        var baseUrl = window.location.host + window.location.pathname,
            baseProtocol = window.location.protocol + '//',
            iTunesProtocol = 'itpc://',
            apiKey = apiKeyField.val();

        $.getJSON('testapikey?key=' + apiKey, null, function(data) {

            if (data.hasOwnProperty('validKey') && data.validKey === true) {

                // Build URLs for the various buttons
                var morningEditionBaseUrl = baseUrl + 'podcasts/morningedition?key=' + apiKey,
                    morningEditionITunesUrl = iTunesProtocol + morningEditionBaseUrl,
                    morningEditionRssUrl = baseProtocol + morningEditionBaseUrl;

                var allThingsConsideredBaseUrl = baseUrl + 'podcasts/allthingsconsidered?key=' + apiKey,
                    allThingsConsideredITunesUrl = iTunesProtocol + allThingsConsideredBaseUrl,
                    allThingsConsideredRssUrl = baseProtocol + allThingsConsideredBaseUrl;

                // Apply the new URLs
                morningEditionITunesButton.attr('href', morningEditionITunesUrl);
                morningEditionRssButton.attr('href', morningEditionRssUrl);

                allThingsConsideredITunesButton.attr('href', allThingsConsideredITunesUrl);
                allThingsConsideredRssButton.attr('href', allThingsConsideredRssUrl);

                // Make the buttons visible
                subscriptionsContainer.removeClass('hidden')
            }

        });
    });

} ());