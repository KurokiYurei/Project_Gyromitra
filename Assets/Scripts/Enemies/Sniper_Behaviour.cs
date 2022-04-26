using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Sniper_Behaviour : MonoBehaviour
{
    [SerializeField]
    private float m_fireRadius;

    [SerializeField]
    private float m_cooldownTime;

    [SerializeField]
    private Transform m_firePoint;

    [SerializeField]
    private LayerMask m_shootLayerMask;

    [SerializeField]
    private float m_sniperDamage;

    private string m_playerTag;
    private float m_timer;


    void Start()
    {
        m_playerTag = UtilsGyromitra.SearchForTag("Player");
    }

    void Update()
    {
        ShootSniper();
    }

    private void ShootSniper()
    {
        GameObject l_player = UtilsGyromitra.FindInstanceWithinRadius(this.gameObject, m_playerTag, m_fireRadius);

        if (l_player != null)
        {
            Vector3 l_playerPos = l_player.transform.position;
            Vector3 l_enemyPos = gameObject.transform.position;

            Vector3 l_direction = l_playerPos - l_enemyPos;

            m_timer += Time.deltaTime;

            if (m_timer >= m_cooldownTime)
            {
                Ray l_ray = new Ray(m_firePoint.position, l_direction);
                RaycastHit l_raycastHit;

                if (Physics.Raycast(l_ray, out l_raycastHit, m_fireRadius, m_shootLayerMask))
                {
                    l_player.GetComponent<CharacterHP>().Damage(m_sniperDamage);

                    print(l_player.tag);
                    Debug.DrawLine(m_firePoint.position, l_raycastHit.point, Color.red);

                    //yield WaitForSeconds(5);
                    m_timer = 0;
                }


            }
        }



    }
}
