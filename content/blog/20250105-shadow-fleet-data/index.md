+++
title = "Shadow Fleet Tracking: AIS Manipulation Data Sources"
date = "2025-01-05"
description = """
  How an amateur might go about tracking the global shadow
  fleet: comparing AIS data against satellite images.
"""
authors = ["Jonathan Merritt"]
extra.summary_image = "preview-markup.jpg"
taxonomies.tags = ["shadow-fleet"]
+++

I had an idea to compare Automatic Identification System (AIS) data against
satellite images to track the global "shadow fleet". This is an initial
exploration, and a couple of possible sources of data to use.

## What is the Shadow Fleet?

The ["shadow fleet"](https://en.wikipedia.org/wiki/Shadow_fleet) most often
refers to the use of un-registered and fraudulent vessels to avoid sanctions. It
has also been used to describe other, intentionally-hidden activities, such as
[over-fishing](https://www.abc.net.au/news/2020-12-19/how-china-is-plundering-the-worlds-oceans/12971422).
However, it is a general and imprecise term.

Recently, I've become interested in the global shadow fleet due to the alleged
used of ship-to-ship transfers of oil, employed to avoid sanctions against
Russia and Iran. This Bloomberg video describes the practice in the seas east of
Malaysia and Singapore:

{{ youtube(id="9NpgzsTrW78", class="youtube") }}

In this post, I'll focus on the [Automatic Identification System
(AIS)](https://en.wikipedia.org/wiki/Automatic_identification_system), which is
a transponder system that reports the identification and position of maritime
vessels. The use of AIS is mandated by the [SOLAS
Convention](https://en.wikipedia.org/wiki/SOLAS_Convention), which was [ratified
by China, Russia and
Iran](https://www.ecolex.org/details/international-convention-for-the-safety-of-life-at-sea-solas-tre-000115/participants/).
Large vessels, like oil tankers and container ships, are expected to have AIS
enabled while they are underway. It is an important system with many primary
uses, such as collision avoidance, maritime security, precision navigation,
search-and-rescue, infrastructure protection (such as undersea cables), cargo
tracking, and accident investigation.

Shadow fleets are known to disable or spoof AIS signals -- [Androjna et al
(2023)](https://www.mdpi.com/2077-1312/12/1/6). They are presumed do this to
obfuscate their precise movements and rendezvous activities. This allows them to
hide things like ship-to-ship cargo transfers. As a result, proving the origin
and chain of custody of cargo, such as oil, becomes more difficult. Ship-to-ship
transfers may occur in international waters, making them very difficult to
inspect or police.

It is widely presumed that shadow fleets operate with the knowledge and
permission of nations like China, Russia and Iran. However, in my opinion, more
specific evidence for this would be welcome. It is possible, albeit naive, to
claim that bad, non-state actors are operating these fleets without the
involvement or approval of sanctioned nations and their allies. Thus, in
principle at least, there are no nationalistic ideological grounds to oppose
detecting AIS bad-actors. In principle, it is a virtuous activity, for the
public good, in all nations that have ratified SOLAS.

## AIS Manipulation Detection: The Literature

I haven't done a thorough review, but after I had this idea, I thought I would
check the academic literature to see if it has already been done.

In the academic literature, work has recently been published which describes a
comparison of AIS data against satellite imagery -- [Androjna et al
(2023)](https://www.mdpi.com/2077-1312/12/1/6). The idea is pretty simple: 
compare AIS reported positions (if they exist) against satellite imagery.

There are some caveats to this process. For example:

- A ship might be out of range of an AIS receiving station.
- Satellite imagery is not available at all times, so comparisons can only be
  performed when satellites are overhead.
- AIS signals can be manipulated by people other than the crew of a vessel.

However, I believe that this technique is worth further investigation. 

## AIS Manipulation Survey

I'm interested to figure out if it's possible to survey AIS and satellite data
systematically, to determine the extent of AIS manipulation. Similar to what
Androjna et al (2023) reported, but with a more systematic focus. This would
involve a bi-directional comparison:

1. In satellite photos, what ships are visible that are large enough that
   they should have a reported AIS position?
1. In AIS data, do the reported locations correspond to places in satellite
   imagery where we find actual ships?
   
The discrepancy between these two measures should give a good indication of the
extent of AIS manipulation in a region. There are, however, many outstanding
questions, such as whether the spatiotemporal resolution of the data are good
enough to permit a comparison.

## Possible Data Sources

So far, I have looked at two data sources: one for satellite imagery, and
one for AIS data.

### Satellite Imagery: The Copernicus Data Space Ecosystem

I signed up for access to the [Copernicus Data Space
Ecosystem](https://dataspace.copernicus.eu/). It has a
[browser](https://browser.dataspace.copernicus.eu/), which permits access to
imagery from various satellites. There is also an API, which I would use for
access in any actual project.

Within the Copernicus mission data, I found the following useful sources:

- [Sentinel 1 (1A)](https://en.wikipedia.org/wiki/Sentinel-1) synthetic aperture 
  radar data, available every 6 days in the South China Sea.
- [Sentinel 2 (L2A)](https://en.wikipedia.org/wiki/Sentinel-2) optical-range
  image data, available every 2-3 days (modulo cloud cover) in the South
  China Sea.

This is an example of a Sentinel 1 image:

{% blogfig(img='sentinel-1.png') %} Sentinel 1 IW (Interferometric Wide Swath)
image. Those bright blobs are ships at sea east of Malaysia. These synthetic
aperture radar (SAR) images can see through clouds. {% end %}

While this one is from Sentinel 2 (acquired at a different time):

{% blogfig(img='sentinel-2a.png') %} Sentinel 2 image. These visual-range images
contain clouds, but the clouds can be masked out. {% end %}

I think both of these image types are very suitable for [object
detection](https://en.wikipedia.org/wiki/Object_detection) models. Such models
could probably be trained using correspondences between AIS and the images.

### AIS Data: Marine Traffic

For AIS data, I found
[MarineTraffic.com](https://servicedocs.marinetraffic.com/). It has a way to
query vessels in an
[area-of-interest](https://servicedocs.marinetraffic.com/tag/MarineTraffic-AIS#operation/exportvessels-custom-area_),
so that seems suitable to find vessels that ought to appear in a satellite
image. Unfortunately, it's not yet clear to me what parts of this data are
available for free, and what parts need a paid subscription.

## Next Stages: API Exploration

The next stage of this project (if I continue) will involve:

1. Using the APIs of both services to fetch example data.
1. Performing correlations manually, to see if I can reliably establish that
   vessels with an AIS location appear in the satellite images.

I would later try to automate this correspondence to train an object-detection
model.