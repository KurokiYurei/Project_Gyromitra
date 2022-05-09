using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.AI;

public class Hit_Collider : MonoBehaviour
{
    public enum THitColliderType
    {
        BODY = 0,
        HEAD
    }

    public THitColliderType m_ColliderType;

    [SerializeField]
    private EnemyBehaviour m_enemy;
    //private Sniper_Behaviour m_enemy;

    [SerializeField]
    private int m_BodyHitAmount;

    [SerializeField]
    private int m_HeadHitAmount;

    /// <summary>
    /// Checks where the enemy got hit and if its vulnerable
    /// </summary>
    public void Hit()
    {
        int l_HitAmount = m_HeadHitAmount;
        if (m_ColliderType == THitColliderType.BODY)
            l_HitAmount = m_BodyHitAmount;
        if (m_enemy.m_mushroomImpact)
        // if (m_enemy.GetMushroomHit())
            l_HitAmount *= 2;
        m_enemy.GetComponent<Enemy1HP>().Damage(l_HitAmount);
    }

    private void OnCollisionEnter(Collision collision)
    {
        if (collision.transform.tag == "Mushroom" && !m_enemy.m_mushroomImpact)
        {
            gameObject.GetComponentInParent<NavMeshAgent>().enabled = false;
            
            m_enemy.m_mushroomImpact = true;

            collision.transform.GetComponent<Mushroom>().DestroyMushroom();
        }
    }
}
