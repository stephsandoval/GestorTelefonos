import{s as ae,n as X,b as le}from"../chunks/scheduler.BvLojk_z.js";import{S as se,i as oe,e as u,s as k,b as O,c as v,d as T,m as Y,h as F,f as S,g as f,n as g,j as te,k as t,r as ne,l as j}from"../chunks/index.FRP66Aq7.js";import{e as Z}from"../chunks/each.D6YF6ztN.js";import{p as re}from"../chunks/stores.B_G52ECs.js";function x(r,e,n){const i=r.slice();return i[4]=e[n],i}function ee(r){let e,n,i=r[4].fecha+"",D,d,b,p=r[4].numeroOrigen+"",L,C,h,E=r[4].numeroDestino+"",q,N,m,s=r[4].condicion+"",o,c,a,H=r[4].horaInicio+"",I,P,M,V=r[4].horaFin+"",A,J,R,w=r[4].duracion+"",B,$;return{c(){e=u("tr"),n=u("td"),D=O(i),d=k(),b=u("td"),L=O(p),C=k(),h=u("td"),q=O(E),N=k(),m=u("td"),o=O(s),c=k(),a=u("td"),I=O(H),P=k(),M=u("td"),A=O(V),J=k(),R=u("td"),B=O(w),$=k(),this.h()},l(_){e=v(_,"TR",{});var l=T(e);n=v(l,"TD",{class:!0});var y=T(n);D=S(y,i),y.forEach(f),d=F(l),b=v(l,"TD",{class:!0});var z=T(b);L=S(z,p),z.forEach(f),C=F(l),h=v(l,"TD",{class:!0});var G=T(h);q=S(G,E),G.forEach(f),N=F(l),m=v(l,"TD",{class:!0});var K=T(m);o=S(K,s),K.forEach(f),c=F(l),a=v(l,"TD",{class:!0});var Q=T(a);I=S(Q,H),Q.forEach(f),P=F(l),M=v(l,"TD",{class:!0});var U=T(M);A=S(U,V),U.forEach(f),J=F(l),R=v(l,"TD",{class:!0});var W=T(R);B=S(W,w),W.forEach(f),$=F(l),l.forEach(f),this.h()},h(){g(n,"class","svelte-p3h6no"),g(b,"class","svelte-p3h6no"),g(h,"class","svelte-p3h6no"),g(m,"class","svelte-p3h6no"),g(a,"class","svelte-p3h6no"),g(M,"class","svelte-p3h6no"),g(R,"class","svelte-p3h6no")},m(_,l){te(_,e,l),t(e,n),t(n,D),t(e,d),t(e,b),t(b,L),t(e,C),t(e,h),t(h,q),t(e,N),t(e,m),t(m,o),t(e,c),t(e,a),t(a,I),t(e,P),t(e,M),t(M,A),t(e,J),t(e,R),t(R,B),t(e,$)},p(_,l){l&1&&i!==(i=_[4].fecha+"")&&j(D,i),l&1&&p!==(p=_[4].numeroOrigen+"")&&j(L,p),l&1&&E!==(E=_[4].numeroDestino+"")&&j(q,E),l&1&&s!==(s=_[4].condicion+"")&&j(o,s),l&1&&H!==(H=_[4].horaInicio+"")&&j(I,H),l&1&&V!==(V=_[4].horaFin+"")&&j(A,V),l&1&&w!==(w=_[4].duracion+"")&&j(B,w)},d(_){_&&f(e)}}}function he(r){let e,n,i="Facturador de servicios telefónicos",D,d,b,p,L,C,h,E,q='<th class="svelte-p3h6no">Fecha</th> <th class="svelte-p3h6no">Número que inicio la llamada</th> <th class="svelte-p3h6no">Número que recibe la llamada</th> <th class="svelte-p3h6no">Tipo de llamada</th> <th class="svelte-p3h6no">Hora de inicio</th> <th class="svelte-p3h6no">Hora de fin</th> <th class="svelte-p3h6no">Cantidad minutos</th>',N,m=Z(r[0]),s=[];for(let o=0;o<m.length;o+=1)s[o]=ee(x(r,m,o));return{c(){e=u("div"),n=u("h1"),n.textContent=i,D=k(),d=u("h2"),b=O("Llamadas de la empresa: "),p=O(r[1]),L=k(),C=u("div"),h=u("table"),E=u("tr"),E.innerHTML=q,N=k();for(let o=0;o<s.length;o+=1)s[o].c();this.h()},l(o){e=v(o,"DIV",{class:!0});var c=T(e);n=v(c,"H1",{class:!0,"data-svelte-h":!0}),Y(n)!=="svelte-fhugsi"&&(n.textContent=i),D=F(c),d=v(c,"H2",{class:!0});var a=T(d);b=S(a,"Llamadas de la empresa: "),p=S(a,r[1]),a.forEach(f),L=F(c),C=v(c,"DIV",{class:!0,id:!0});var H=T(C);h=v(H,"TABLE",{class:!0});var I=T(h);E=v(I,"TR",{"data-svelte-h":!0}),Y(E)!=="svelte-d69xv7"&&(E.innerHTML=q),N=F(I);for(let P=0;P<s.length;P+=1)s[P].l(I);I.forEach(f),H.forEach(f),c.forEach(f),this.h()},h(){g(n,"class","svelte-p3h6no"),g(d,"class","svelte-p3h6no"),g(h,"class","svelte-p3h6no"),g(C,"class","lista"),g(C,"id","lista"),g(e,"class","main")},m(o,c){te(o,e,c),t(e,n),t(e,D),t(e,d),t(d,b),t(d,p),t(e,L),t(e,C),t(C,h),t(h,E),t(h,N);for(let a=0;a<s.length;a+=1)s[a]&&s[a].m(h,null)},p(o,[c]){if(c&1){m=Z(o[0]);let a;for(a=0;a<m.length;a+=1){const H=x(o,m,a);s[a]?s[a].p(H,c):(s[a]=ee(H),s[a].c(),s[a].m(h,null))}for(;a<s.length;a+=1)s[a].d(1);s.length=m.length}},i:X,o:X,d(o){o&&f(e),ne(s,o)}}}function ce(r,e,n){let i;le(r,re,p=>n(2,i=p));let D=i.url.searchParams.get("empresa"),d=[];return(async()=>{await fetch("http://localhost:8080/api/getLlamadasEmpresa",{method:"POST",body:JSON.stringify({empresa:D})}).then(p=>{p.json().then(L=>{n(0,d=L)})})})(),[d,D]}class ve extends se{constructor(e){super(),oe(this,e,ce,he,ae,{})}}export{ve as component};
