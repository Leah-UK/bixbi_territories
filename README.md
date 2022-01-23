<h1 align='center'><a href='https://discord.link/bixbi'>Discord</a></h1>
<p align='center'><a href='https://forum.cfx.re/u/Leah_UK/summary'>FiveM Profile</a> | <a href='https://ko-fi.com/bixbi'>Support Me Here</a><br></p>

---

<h2 align='center'>Information</h2>



<h3 align='center'><b><a href='https://www.youtube.com/watch?v=kKPt9KeipG0'>Demonstration Video</a></b></h3>

---

<h2 align='center'>Requirements</h2>

- OneSync <b>Infinity</b>
- <a href='https://github.com/overextended/es_extended'>"Ox" ESX</a>,<i> You can modify for other frameworks. <b>Please make a PR if you do</b></i>
- <a href='https://github.com/Leah-UK/bixbi_core'>bixbi_core</a>
- <a href='https://github.com/overextended/qtarget'>qtarget</a>
- <a href='https://github.com/zf-development/zf_context'>zf_context</a> (Optional)


---

<h2 align='center'>Exports</h2>

<b>Open Menu</b>
<code>TriggerClientEvent('bixbi_territories:TerritoryInfoMenu')</code>

<b>Sale Complete</b>
<code>TriggerServerEvent('bixbi_territories:sv_Sale', source, zone, type*, amount*, item*, count*)</code>
<i><b>*</b> = Optional. If location is nil you need to supply localPlayerId, and vice-versa.</i>

<i>Example:</i> <code>TriggerServerEvent('bixbi_territories:sv_Sale', source, GetNameOfZone(GetEntityCoords(PlayerPedId())), 'moneywash')</code>

---

<p align='center'><i>Feel free to modify to your liking. Please keep my name <b>(Leah#0001)</b> in the credits of the fxmanifest. <b>If your modification is a bug-fix I ask that you make a pull request, this is a free script; please contribute when you can.</b></i></p>
