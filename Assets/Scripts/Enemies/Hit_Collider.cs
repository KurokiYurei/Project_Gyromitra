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
        if (m_enemy.GetMushroomHit())
            l_HitAmount *= 2;
        m_enemy.GetComponent<Enemy1HP>().Damage(l_HitAmount);
    }

    private void OnCollisionEnter(Collision collision)
    {
        if (collision.transform.tag == "Mushroom")
        {
            if(!m_enemy.m_mushroomImpact && m_enemy.GetAntiSpamTime() <= 0f && collision.GetContact(0).normal.y >= 0.05f)
            {
                m_enemy.m_mushroomImpact = true;
            }
            StartCoroutine(Destroy(collision.transform.GetComponent<Mushroom>()));
        }
    }

    IEnumerator Destroy(Mushroom mushroom)
    {
        yield return new WaitForSeconds(0.5f);

        mushroom.DestroyMushroom();
    }
}
