using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.AI;

public class Hit_Collider : MonoBehaviour
{
    public enum THitColliderType
    {
        BODY = 0,
        HEAD,
        STUN
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

        if(m_ColliderType==THitColliderType.STUN)
        {
            CreateMushroom();
            l_HitAmount=m_BodyHitAmount;
        }
        if(m_ColliderType == THitColliderType.BODY)
            l_HitAmount = m_BodyHitAmount;
        if(m_enemy.GetMushroomHit())
            l_HitAmount *= 2;
        m_enemy.GetComponent<Enemy1HP>().Damage(l_HitAmount);

        StartCoroutine(ChangeMaterial());
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

    void CreateMushroom()
    {
        GameObject l_Mushroom = null;
        l_Mushroom=CharacterControllerScript.GetMushroomPool().GetNextElement(true);
        l_Mushroom.GetComponent<Mushroom>().SetCurrentTime(0f);
        l_Mushroom.GetComponent<Mushroom>().transform.localScale = new Vector3(0, 0, 0);
        l_Mushroom.transform.position=transform.parent.transform.position;
        l_Mushroom.transform.SetParent(null);
        l_Mushroom.SetActive(true);
    }

    IEnumerator Destroy(Mushroom mushroom)
    {
        yield return new WaitForSeconds(0.5f);

        mushroom.DestroyMushroom();
    }
    IEnumerator ChangeMaterial()
    {
        m_enemy.m_golemMaterial.SetColor("_EmissionColor", Color.red);
        yield return new WaitForSeconds(0.2f);
        if(m_enemy.m_mushroomImpact)
            m_enemy.m_golemMaterial.SetColor("_EmissionColor", new Color(222, 58, 0, 100) * 0.01f);
        else
            m_enemy.m_golemMaterial.SetColor("_EmissionColor", new Color(56, 0, 116, 100) * 0.01f);
    }
}
